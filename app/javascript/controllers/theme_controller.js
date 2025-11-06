import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]

  connect() {
    this.themes = ["classic", "dark"]
    this.legacyThemeMap = { midnight: "dark" }
    const activeTheme = this.#determineTheme()

    this.#applyTheme(activeTheme)
    this.#syncUI(activeTheme)
  }

  toggleClick(event) {
    event.preventDefault()
    const current = this.#normalizeTheme(document.documentElement.getAttribute("data-theme")) || this.themes[0]
    const next = current === "dark" ? "classic" : "dark"

    this.#applyTheme(next)
    this.#persistTheme(next)
    this.#syncUI(next)
  }

  handleKeydown(event) {
    if (event.key === " " || event.key === "Spacebar") {
      event.preventDefault()
      this.toggleClick(event)
    }

    if (event.key === "Enter") {
      event.preventDefault()
      this.toggleClick(event)
    }
  }

  #determineTheme() {
    const storedRaw = this.#readStoredTheme()
    const stored = this.#normalizeTheme(storedRaw)

    if (stored) {
      if (stored !== storedRaw) {
        this.#persistTheme(stored)
      }
      return stored
    } else if (storedRaw) {
      this.#clearStoredTheme()
    }

    const current = this.#normalizeTheme(document.documentElement.getAttribute("data-theme"))
    if (current) return current

    return this.themes[0]
  }

  #applyTheme(theme) {
    if (typeof document === "undefined") return
    document.documentElement.setAttribute("data-theme", theme)
  }

  #persistTheme(theme) {
    if (typeof window === "undefined") return
    try {
      window.localStorage.setItem("preferred-theme", theme)
    } catch (error) {
      console.warn("Unable to save theme preference", error)
    }
  }

  #readStoredTheme() {
    if (typeof window === "undefined") return null
    try {
      return window.localStorage.getItem("preferred-theme")
    } catch (error) {
      console.warn("Unable to read theme preference", error)
      return null
    }
  }

  #clearStoredTheme() {
    if (typeof window === "undefined") return
    try {
      window.localStorage.removeItem("preferred-theme")
    } catch (error) {
      console.warn("Unable to clear theme preference", error)
    }
  }

  #normalizeTheme(theme) {
    if (!theme) return null
    const normalized = this.legacyThemeMap?.[theme] || theme
    return this.themes.includes(normalized) ? normalized : null
  }

  #syncUI(theme) {
    const isDark = theme === "dark"

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-checked", String(isDark))
      this.buttonTarget.classList.toggle("is-dark", isDark)
    }

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = isDark ? "Dark" : "Classic"
    }
  }
}


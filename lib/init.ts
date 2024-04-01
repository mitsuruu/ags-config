import css from "style/style"
import matugen from "./matugen"
import hyprland from "./hyprland"
import tmux from "./tmux"
import gtk from "./gtk"
import lowBattery from "./battery"

export async function init() {
    try {
        gtk()
        css()
        tmux()
        matugen()
        lowBattery()
        hyprland()
        css()
    } catch (error) {
        logError(error)
    }
}

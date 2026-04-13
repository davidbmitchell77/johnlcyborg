public with sharing class SYS_UTILS {
    public static String apexClassName(String s) {
        return ((!String.isBlank(s)) ? s.substring(0, s.indexOf(':')) : '');
    }
}
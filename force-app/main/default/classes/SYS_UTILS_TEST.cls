@isTest
private class SYS_UTILS_TEST {
    @isTest
    private static void test01_apexClassName() {
        String s = 'TheTestClass';
        System.assertEquals(s, SYS_UTILS.apexClassName(s + ':'));
    }
}
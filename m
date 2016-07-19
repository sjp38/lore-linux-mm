Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1956B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:14:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so57609164pfa.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:14:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bs7si34362790pab.49.2016.07.19.13.14.43
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 13:14:43 -0700 (PDT)
Date: Wed, 20 Jul 2016 04:18:58 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [jirislaby-stable:stable-3.12-queue 4592/5330]
 arch/um/include/shared/init.h:129:26: error: expected '=', ',', ';', 'asm'
 or '__attribute__' before '__used'
Message-ID: <201607200454.0b8kp04y%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Jiri Slaby <jslaby@suse.cz>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/jirislaby/linux-stable.git stable-3.12-queue
head:   4df2158fe690a10d115965bee2602ac8100ba9c2
commit: 1fa9b58c6284c20971a0750acb9b17b22775151d [4592/5330] compiler-gcc: integrate the various compiler-gcc[345].h files
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        git checkout 1fa9b58c6284c20971a0750acb9b17b22775151d
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

All errors (new ones prefixed by >>):

   In file included from arch/um/drivers/chan_user.h:9:0,
                    from arch/um/drivers/xterm.c:13:
>> arch/um/include/shared/init.h:129:26: error: expected '=', ',', ';', 'asm' or '__attribute__' before '__used'
    #define __uml_setup_help __used __section(.uml.help.init)
                             ^
   arch/um/include/shared/init.h:122:37: note: in expansion of macro '__uml_setup_help'
     static const char *__uml_help_##fn __uml_setup_help = __uml_help_str_##fn
                                        ^~~~~~~~~~~~~~~~
   arch/um/include/shared/init.h:111:2: note: in expansion of macro '__uml_help'
     __uml_help(fn, help);      \
     ^~~~~~~~~~
   arch/um/drivers/xterm.c:71:1: note: in expansion of macro '__uml_setup'
    __uml_setup("xterm=", xterm_setup,
    ^~~~~~~~~~~
   arch/um/include/shared/init.h:128:26: error: expected '=', ',', ';', 'asm' or '__attribute__' before '__used'
    #define __uml_init_setup __used __section(.uml.setup.init)
                             ^
   arch/um/include/shared/init.h:113:43: note: in expansion of macro '__uml_init_setup'
     static struct uml_param __uml_setup_##fn __uml_init_setup = { __uml_setup_str_##fn, fn }
                                              ^~~~~~~~~~~~~~~~
   arch/um/drivers/xterm.c:71:1: note: in expansion of macro '__uml_setup'
    __uml_setup("xterm=", xterm_setup,
    ^~~~~~~~~~~
   arch/um/include/shared/init.h:112:14: warning: '__uml_setup_str_xterm_setup' defined but not used [-Wunused-variable]
     static char __uml_setup_str_##fn[] __initdata = str;  \
                 ^
   arch/um/drivers/xterm.c:71:1: note: in expansion of macro '__uml_setup'
    __uml_setup("xterm=", xterm_setup,
    ^~~~~~~~~~~
   arch/um/include/shared/init.h:121:14: warning: '__uml_help_str_xterm_setup' defined but not used [-Wunused-variable]
     static char __uml_help_str_##fn[] __initdata = help;  \
                 ^
   arch/um/include/shared/init.h:111:2: note: in expansion of macro '__uml_help'
     __uml_help(fn, help);      \
     ^~~~~~~~~~
   arch/um/drivers/xterm.c:71:1: note: in expansion of macro '__uml_setup'
    __uml_setup("xterm=", xterm_setup,
    ^~~~~~~~~~~
   arch/um/drivers/xterm.c:47:19: warning: 'xterm_setup' defined but not used [-Wunused-function]
    static int __init xterm_setup(char *line, int *add)
                      ^~~~~~~~~~~

vim +129 arch/um/include/shared/init.h

^1da177e arch/um/include/init.h Linus Torvalds 2005-04-16  123  
^1da177e arch/um/include/init.h Linus Torvalds 2005-04-16  124  /*
^1da177e arch/um/include/init.h Linus Torvalds 2005-04-16  125   * Mark functions and data as being only used at initialization
^1da177e arch/um/include/init.h Linus Torvalds 2005-04-16  126   * or exit time.
^1da177e arch/um/include/init.h Linus Torvalds 2005-04-16  127   */
3ff6eecc arch/um/include/init.h Adrian Bunk    2008-01-24  128  #define __uml_init_setup	__used __section(.uml.setup.init)
3ff6eecc arch/um/include/init.h Adrian Bunk    2008-01-24 @129  #define __uml_setup_help	__used __section(.uml.help.init)
3ff6eecc arch/um/include/init.h Adrian Bunk    2008-01-24  130  #define __uml_init_call		__used __section(.uml.initcall.init)
3ff6eecc arch/um/include/init.h Adrian Bunk    2008-01-24  131  #define __uml_postsetup_call	__used __section(.uml.postsetup.init)
3ff6eecc arch/um/include/init.h Adrian Bunk    2008-01-24  132  #define __uml_exit_call		__used __section(.uml.exitcall.exit)

:::::: The code at line 129 was first introduced by commit
:::::: 3ff6eecca4e5c49a5d1dd8b58ea0e20102ce08f0 remove __attribute_used__

:::::: TO: Adrian Bunk <bunk@kernel.org>
:::::: CC: Sam Ravnborg <sam@ravnborg.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--TB36FDmn/VVEgNH/
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
TDfZtwgZ+gM77Gbym1cAAA==

--TB36FDmn/VVEgNH/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

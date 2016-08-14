Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6349A6B0005
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 18:17:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so87062797pfg.2
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 15:17:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id j80si22984212pfa.194.2016.08.14.15.17.53
        for <linux-mm@kvack.org>;
        Sun, 14 Aug 2016 15:17:53 -0700 (PDT)
Date: Mon, 15 Aug 2016 06:17:20 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-stable-rc:linux-3.14.y 4656/4884]
 arch/um/include/shared/init.h:129:26: error: expected '=', ',', ';', 'asm'
 or '__attribute__' before '__used'
Message-ID: <201608150616.XoPPfW8R%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joe,

FYI, the error/warning still remains.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
head:   43ef7e3ec8016449b3b0afdeaee89053687d1680
commit: 3711edaf01a01818f2aed9f21efe29b9818134b9 [4656/4884] compiler-gcc: integrate the various compiler-gcc[345].h files
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        git checkout 3711edaf01a01818f2aed9f21efe29b9818134b9
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

--G4iJoqBmSsgzjUCe
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--G4iJoqBmSsgzjUCe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

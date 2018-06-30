Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B078A6B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 23:27:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id p91-v6so6023574plb.12
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 20:27:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a8-v6si8995158pgu.544.2018.06.29.20.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 20:27:15 -0700 (PDT)
Date: Sat, 30 Jun 2018 11:26:42 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v3] add param that allows bootline control of hardened
 usercopy
Message-ID: <201806301119.XfeSGQJm%fengguang.wu@intel.com>
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline
In-Reply-To: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: kbuild-all@01.org, keescook@chromium.org, labbott@redhat.com, pabeni@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Chris,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.18-rc2 next-20180629]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Chris-von-Recklinghausen/add-param-that-allows-bootline-control-of-hardened-usercopy/20180627-204733
config: m68k-hp300_defconfig (attached as .config)
compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

   In file included from include/linux/thread_info.h:113:0,
                    from include/asm-generic/preempt.h:5,
                    from ./arch/m68k/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:81,
                    from arch/m68k/include/asm/irqflags.h:6,
                    from include/linux/irqflags.h:16,
                    from arch/m68k/include/asm/atomic.h:6,
                    from include/linux/atomic.h:5,
                    from include/linux/rcupdate.h:38,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from arch/m68k/kernel/asm-offsets.c:15:
   include/linux/jump_label.h: In function 'static_key_count':
>> include/linux/jump_label.h:194:9: error: implicit declaration of function 'atomic_read'; did you mean '__atomic_load'? [-Werror=implicit-function-declaration]
     return atomic_read(&key->enabled);
            ^~~~~~~~~~~
            __atomic_load
   include/linux/jump_label.h: In function 'static_key_slow_inc':
>> include/linux/jump_label.h:221:2: error: implicit declaration of function 'atomic_inc'; did you mean '__atomic_load'? [-Werror=implicit-function-declaration]
     atomic_inc(&key->enabled);
     ^~~~~~~~~~
     __atomic_load
   include/linux/jump_label.h: In function 'static_key_slow_dec':
>> include/linux/jump_label.h:227:2: error: implicit declaration of function 'atomic_dec'; did you mean '__atomic_clear'? [-Werror=implicit-function-declaration]
     atomic_dec(&key->enabled);
     ^~~~~~~~~~
     __atomic_clear
   include/linux/jump_label.h: In function 'static_key_enable':
>> include/linux/jump_label.h:254:2: error: implicit declaration of function 'atomic_set'; did you mean '__atomic_clear'? [-Werror=implicit-function-declaration]
     atomic_set(&key->enabled, 1);
     ^~~~~~~~~~
     __atomic_clear
   In file included from include/linux/atomic.h:5:0,
                    from include/linux/rcupdate.h:38,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from arch/m68k/kernel/asm-offsets.c:15:
   arch/m68k/include/asm/atomic.h: At top level:
   arch/m68k/include/asm/atomic.h:125:20: warning: conflicting types for 'atomic_inc'
    static inline void atomic_inc(atomic_t *v)
                       ^~~~~~~~~~
>> arch/m68k/include/asm/atomic.h:125:20: error: static declaration of 'atomic_inc' follows non-static declaration
   In file included from include/linux/thread_info.h:113:0,
                    from include/asm-generic/preempt.h:5,
                    from ./arch/m68k/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:81,
                    from arch/m68k/include/asm/irqflags.h:6,
                    from include/linux/irqflags.h:16,
                    from arch/m68k/include/asm/atomic.h:6,
                    from include/linux/atomic.h:5,
                    from include/linux/rcupdate.h:38,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from arch/m68k/kernel/asm-offsets.c:15:
   include/linux/jump_label.h:221:2: note: previous implicit declaration of 'atomic_inc' was here
     atomic_inc(&key->enabled);
     ^~~~~~~~~~
   In file included from include/linux/atomic.h:5:0,
                    from include/linux/rcupdate.h:38,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from arch/m68k/kernel/asm-offsets.c:15:
   arch/m68k/include/asm/atomic.h:130:20: warning: conflicting types for 'atomic_dec'
    static inline void atomic_dec(atomic_t *v)
                       ^~~~~~~~~~
>> arch/m68k/include/asm/atomic.h:130:20: error: static declaration of 'atomic_dec' follows non-static declaration
   In file included from include/linux/thread_info.h:113:0,
                    from include/asm-generic/preempt.h:5,
                    from ./arch/m68k/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:81,
                    from arch/m68k/include/asm/irqflags.h:6,
                    from include/linux/irqflags.h:16,
                    from arch/m68k/include/asm/atomic.h:6,
                    from include/linux/atomic.h:5,
                    from include/linux/rcupdate.h:38,
                    from include/linux/rculist.h:11,
                    from include/linux/pid.h:5,
                    from include/linux/sched.h:14,
                    from arch/m68k/kernel/asm-offsets.c:15:
   include/linux/jump_label.h:227:2: note: previous implicit declaration of 'atomic_dec' was here
     atomic_dec(&key->enabled);
     ^~~~~~~~~~
   cc1: some warnings being treated as errors
   make[2]: *** [arch/m68k/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +194 include/linux/jump_label.h

1f69bf9c6 Jason Baron          2016-08-03  191  
4c5ea0a9c Paolo Bonzini        2016-06-21  192  static inline int static_key_count(struct static_key *key)
4c5ea0a9c Paolo Bonzini        2016-06-21  193  {
4c5ea0a9c Paolo Bonzini        2016-06-21 @194  	return atomic_read(&key->enabled);
4c5ea0a9c Paolo Bonzini        2016-06-21  195  }
4c5ea0a9c Paolo Bonzini        2016-06-21  196  
97ce2c88f Jeremy Fitzhardinge  2011-10-12  197  static __always_inline void jump_label_init(void)
97ce2c88f Jeremy Fitzhardinge  2011-10-12  198  {
c4b2c0c5f Hannes Frederic Sowa 2013-10-19  199  	static_key_initialized = true;
97ce2c88f Jeremy Fitzhardinge  2011-10-12  200  }
97ce2c88f Jeremy Fitzhardinge  2011-10-12  201  
578ae447e Josh Poimboeuf       2018-03-19  202  static inline void jump_label_invalidate_initmem(void) {}
333522447 Josh Poimboeuf       2018-02-20  203  
c5905afb0 Ingo Molnar          2012-02-24  204  static __always_inline bool static_key_false(struct static_key *key)
c5905afb0 Ingo Molnar          2012-02-24  205  {
ea5e9539a Mel Gorman           2014-06-04  206  	if (unlikely(static_key_count(key) > 0))
c5905afb0 Ingo Molnar          2012-02-24  207  		return true;
c5905afb0 Ingo Molnar          2012-02-24  208  	return false;
c5905afb0 Ingo Molnar          2012-02-24  209  }
c5905afb0 Ingo Molnar          2012-02-24  210  
c5905afb0 Ingo Molnar          2012-02-24  211  static __always_inline bool static_key_true(struct static_key *key)
d430d3d7e Jason Baron          2011-03-16  212  {
ea5e9539a Mel Gorman           2014-06-04  213  	if (likely(static_key_count(key) > 0))
d430d3d7e Jason Baron          2011-03-16  214  		return true;
d430d3d7e Jason Baron          2011-03-16  215  	return false;
d430d3d7e Jason Baron          2011-03-16  216  }
bf5438fca Jason Baron          2010-09-17  217  
c5905afb0 Ingo Molnar          2012-02-24  218  static inline void static_key_slow_inc(struct static_key *key)
d430d3d7e Jason Baron          2011-03-16  219  {
5cdda5117 Borislav Petkov      2017-10-18  220  	STATIC_KEY_CHECK_USE(key);
d430d3d7e Jason Baron          2011-03-16 @221  	atomic_inc(&key->enabled);
d430d3d7e Jason Baron          2011-03-16  222  }
bf5438fca Jason Baron          2010-09-17  223  
c5905afb0 Ingo Molnar          2012-02-24  224  static inline void static_key_slow_dec(struct static_key *key)
bf5438fca Jason Baron          2010-09-17  225  {
5cdda5117 Borislav Petkov      2017-10-18  226  	STATIC_KEY_CHECK_USE(key);
d430d3d7e Jason Baron          2011-03-16 @227  	atomic_dec(&key->enabled);
bf5438fca Jason Baron          2010-09-17  228  }
bf5438fca Jason Baron          2010-09-17  229  
ce48c1464 Peter Zijlstra       2018-01-22  230  #define static_key_slow_inc_cpuslocked(key) static_key_slow_inc(key)
ce48c1464 Peter Zijlstra       2018-01-22  231  #define static_key_slow_dec_cpuslocked(key) static_key_slow_dec(key)
ce48c1464 Peter Zijlstra       2018-01-22  232  
4c3ef6d79 Jason Baron          2010-09-17  233  static inline int jump_label_text_reserved(void *start, void *end)
4c3ef6d79 Jason Baron          2010-09-17  234  {
4c3ef6d79 Jason Baron          2010-09-17  235  	return 0;
4c3ef6d79 Jason Baron          2010-09-17  236  }
4c3ef6d79 Jason Baron          2010-09-17  237  
91bad2f8d Jason Baron          2010-10-01  238  static inline void jump_label_lock(void) {}
91bad2f8d Jason Baron          2010-10-01  239  static inline void jump_label_unlock(void) {}
91bad2f8d Jason Baron          2010-10-01  240  
d430d3d7e Jason Baron          2011-03-16  241  static inline int jump_label_apply_nops(struct module *mod)
d430d3d7e Jason Baron          2011-03-16  242  {
d430d3d7e Jason Baron          2011-03-16  243  	return 0;
d430d3d7e Jason Baron          2011-03-16  244  }
b20295207 Gleb Natapov         2011-11-27  245  
e33886b38 Peter Zijlstra       2015-07-24  246  static inline void static_key_enable(struct static_key *key)
e33886b38 Peter Zijlstra       2015-07-24  247  {
5cdda5117 Borislav Petkov      2017-10-18  248  	STATIC_KEY_CHECK_USE(key);
e33886b38 Peter Zijlstra       2015-07-24  249  
1dbb6704d Paolo Bonzini        2017-08-01  250  	if (atomic_read(&key->enabled) != 0) {
1dbb6704d Paolo Bonzini        2017-08-01  251  		WARN_ON_ONCE(atomic_read(&key->enabled) != 1);
1dbb6704d Paolo Bonzini        2017-08-01  252  		return;
1dbb6704d Paolo Bonzini        2017-08-01  253  	}
1dbb6704d Paolo Bonzini        2017-08-01 @254  	atomic_set(&key->enabled, 1);
e33886b38 Peter Zijlstra       2015-07-24  255  }
e33886b38 Peter Zijlstra       2015-07-24  256  

:::::: The code at line 194 was first introduced by commit
:::::: 4c5ea0a9cd02d6aa8adc86e100b2a4cff8d614ff locking/static_key: Fix concurrent static_key_slow_inc()

:::::: TO: Paolo Bonzini <pbonzini@redhat.com>
:::::: CC: Ingo Molnar <mingo@kernel.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--zhXaljGHf11kAtnf
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICDzzNlsAAy5jb25maWcAlDzbcts4su/zFaxM1amZ2s2sY2e0mT3lBxAERaxIggFA2c4L
S3GUjGts2SvJc/n70w3eABKQ9lSlYrG7ce870fz+u+8j8np8ftocH+43j49/Rd+2u+1+c9x+
ib4+PG7/N0pEVAodsYTrn4A4f9i9/vmPp8WH36L3P7378NPF2/39ZbTa7nfbx4g+774+fHuF
5g/Pu+++/w7+fQ/Apxfoaf+vCFu9fcQO3n7bvb79dn8f/ZBsPz9sdtE/f7qErt69+7H9BQ2p
KFO+bIrFh9X1X/0Treomhr+sTDgpR7i8UaxolqxkktNGVbzMBbXa9ZjshvFlpucISnIeS6JZ
k7Cc3I0EmhesycVNI5kaoaVouKiE1E1BqhH8SZTQQUFGSPbp+t3FRf9ULTWJc+iPrVmurq+G
ZdGGq2ZJqTUxgK2ZVFyU1/+8uBz7oDkplwNqAHP5sbkREtdsdn1pjvExOmyPry/jdsZSrFjZ
iLJRhTVxXnINm7puiFw2OS+4vr66xLPrxhRFxWHemikdPRyi3fMRO+5bw16TvJ/Rm7e/vlxd
XLzxIRtSazGOmrCU1LluMqF0SQp2/eaH3fNu++PQVt3Yu6vu1JpXdAbAv1TnI7wSit82xcea
1cwPnTWhUijVFKwQ8q4hWhOajchaMeAOeB42hNQgDvZOmD2HM4gOr58Pfx2O26dxz3sewyNS
mbgZOyaSZtg7nD3TyGkiTRXT/RkCt/9Dbw6/RceHp2202X2JDsfN8RBt7u+fX3fHh923cRDN
6cqIB6FU1KXm5XIcJ1ZJU0lBGawR8DqMadZX9jo1USuliVaztUpaR2q+Vhj3rgGc3Qk8Nuy2
YtLHO6oltpurSXu+an94OQ+WUKewrTzV1+8Ww1lLXupVo0jKpjRXFlsvpagr5ekXuVFVhBqZ
H+hrrZrSIR/nCGwYQMH5yhCu4kkIVTIdQimascTIklmAn+ZOpQokrJKMglpLvEQSdZ1n+XG+
gqZroxZk4qoJSQroWIlaUhDYQVRl0iw/cUtaARAD4NKB5J9s5QiA208TvJg8v7cPAHSiqEBO
+CfWpEI2wFPwpyAlZZ5VTKkV/HCUh6MBSAn6iZcisfV8RtasqXnybmGJTJXacwpy9qRZAZqO
Iy9YUwCpL0DCzFxInjuTw02egtOMlEk+02moOaQ165b7rRnXli5geQr6XFqdxETBBtXOQLVm
t5NHYNbJxrRgWlS3NLNHqISzFr4sSZ4mtpTDfG0AmMNS2wCVgSq2zoZbbEGSNVes3xxr2dAk
JlJye4tXSHJXqDmkXTZKgOZr5hzvfOPx3IytMpMcz76IWZK4wmW0Y+cPVdv91+f902Z3v43Y
79sd6G4CWpyi9t7uD6PaXBftHjRGdzuHibaXaDDc1oGqnDjmSOV17NOtQAa7IpesN7VuI8Cm
koFtU7qRwFmi8CspKVKeg0HxyZgkKpvw04rdMjqBGUt3Q2CFqCkrImHve49h5Nu8XvLSuAPg
Cr359re/DeoFZDkjIBFgmFcwH82oBokGkWUTnixE0g6mKkZ5yi13AVB1DrYWDtNIAZ79SeyI
FHmCfKxq6LVMrmYIQnW7Eku1puYsjWDN+GNJxfrt580BvOzfWlZ52T+Dv+2YdPQuUcJshWSY
VhXInBeTmdujtyDUehQNIEk8R9fR1CXig41btJcvgK47Qr+Z6voBcz64f+5WzChdGz9FoySA
F+4fTEtewGTh9JJmhfLtNWtOUJDHCUmtrQWjp6jicHTgIyrtYtAcxmrpBbbO4cx2araUXN/Z
W9sjMVDwbypS0CIBcWOtmMgg2U2sgzjcBlGROedVm/3xAcOzSP/1srVUEAymuTanlKzRojo8
QUCcy5HGOy4BU3SaQqjUT9H3UIAojRSW+tBEch+iINQLVolQPgT6uwlXK9B9tnwX4NncNqqO
PU2UyGFw1dx+WPh6rKHlDZHM6XZYcZ4UZ/ZELfkZCtDbMrS1fSd16cxtaLsi4B6d6Z+lgRlY
Ydbig79/i1Xn7dugSETq/tftl9dHx+Jx0XqxpRB2HNpBE0ZMv9dPUwxNP84DyBY4TKoHY9+e
9fTorsvrN/df/zMYmuLjiUlYyNVdDH7GbHoxzGQAElW+s0hKs1OYnDBaFeI1iAht59rgJYza
4U/hvG1vQN+wUGMb6bYuitp5AIUL1lXY1tHYdEuMhIBQLRUmduzD1epxc0R3Z8g5tND98/32
cHjeG4XjJnZoTpQyJtpKNeRJyqXPn4cWF5cX1kzh+Wry/H7yvLgYZjfMQ71s7x++PtxH4gUV
4aGNtcdZpRBFs6L267hON/qUF3odoATgUfMlOKMNKzHbY2eNILjo4tAx9wOjoWtDkgSNWzOE
nb3vXdX9EorN/a8Pu+2gucdZod70zxcVp9+oEupvgd678KLWhe9Ysurq4sJxLOvy6tbbwcf3
FzP9EL8eIvX68vK8P47MkRiH33al0+3m+Lq3DZa91dZ2gT9vNhrDATc7VzIQUBOGVeBNTCI9
VeVcN5U20gFnoq7fu/mv1sXzeRXg5lHrlNccHDctIOpyXLKVKk7oogJmilbIsMH1+4tfFs6s
IcQ0jLKyVkpzBqxIQO3Yw6QS9gTzZp7BPlVC5KCQBuJPce33Qj5dpSCHfpTxPoWfeThEp2AL
IODQEjz1ScwwRhRM4mpmmaWBYFlXTcxKmhVErmYsw/7c3r8eN58ftyZHHZkY62ixRgy6qdDo
xjtxbxeSWMeKZrsuquEY0PHPQMmCv+o76bZbRSWvnFCqQyDv+QQE4xIiatujbBsY4NMEWABf
j0CcI07RZmPtPIB+X6Lm6AWm3B7/eN7/BqFE9DwouMHJoyu7efsMokSW45Do0bj+zYRAQ9Rt
cRE8olPLvUmY21RaPItPjUjTLuSwoSRfCntPDbAO+b8GC/5aA9qKU18Oy1CAXsSk/qxf5DyI
ejn1HbOhgDAVhH5cM270ijnOfAfqB/HPM6nAgcRN9o3E27O0soitfqJE+V17IOgtUCOBedzd
GYkMrmnNq52/q5qqrKbPTZLRORBN/Bwqiawm3FfxyTbxaolyBSb0dopodF2WLPfQjyB1VwLX
ixV3XrgYurXmbtM68XeZinoGGIe3+sUTaEhme2kAYKqaQwa+dTFTRjFAw0LTiRmMF9jyKhot
UJulwhdLYYrTHcSMTdu6wtvOglY+MG6nByzJTQ8eObHvGQ5aaSnuvPyK48DPk37TQEPr2E7X
9Dq5x4Of/vr54f6N23uR/Ky8rwaAWxbWOuCpkxjwWVnqSl2Pa9CnDQge0LTZZFQbTeJNqeCm
LGbstJjz0yLMUIuRo9zRC14tAutsOPjqk16CLLgIQM8y4eIMFy7mbOiwi403291l50nAsTIr
c0TeQBTXs70BWLOQ3iNBdIm+ovH49F3FbKW29uwGAh2NZCCOSukhY+PJWfVepnnfG3plhIRm
I8J4xZaLJr9phzlDloVceth7fDUMVHTqT1kqstJVZzHSqZkzravszmTuwXYWlT8bDKQpz7Wd
gB9Adlqpd3gkT8BVHFs99TcG9lt0Y8C5O273s1sFs55HB2iGgl8Q/K4cY9ChUoia8rtuEr62
HcHU4rk9t+9TPd33+PYt9AmCXFj6tsSXM2VpvGcHim8xQS0UopyBoSNwv3xDYFcmC+0foEFu
sNZmozBD6cQvDhbD/jTw3tKmMy81/gs68+679vs8M0LDgD7uswlNJm62AI0zh9gsoTTUQ0/i
aAAboajtF9kYMJ8QRLLAjpKClAkJnESqqwAmu7q8CqC4pAFMLMGuoBcZwAOLxFzg2+wAgSqL
0ISqKjhXRUoWQvFQI92ufXJOnXQEOWKg8PHOSFcSdwtKzA5ARG2roQ4cPsMROzt7RHkOFsHT
I0XY9MQQNt0ZhGlfYwgEuWRU+7QROM0ww9s7p5FQqfPcGiMPqA9EZvBOtVgY2L66WDJHC+nG
UYEpRsLiZu7eIEahPxlrydgcnhGVzaEx15jGccdrX5O6bKMNU5nbS15m0FNVq7urTg6oIOqj
CzH77oImbKUbEf8bvUoHNtX8BiQ0mfb+bzbdvhbWnspk3fgy2IXNdy3l8QzQd+bsVxuZ+iUn
qau5ZYE2IXh6k/jhMPYc3nJIextuukwL5zNqtwMbG2fh1iSCDtH989Pnh932S/T0jO8aDj5H
4Va3Js/bq+GeE2hlZumMedzsv22PoaE0kUvgX5oxulJ1Eei2p+o9r9NUp6fYU3kdkhGfKFqd
psjyM/jzk8BUoLnocZrMFUkPwYmRXCn0tC3ZRHX4aNKzUyjToBNnEYmp0+YhwjwRU2dmPej5
k1SanZmQnhoEHw1M+Vw3tCqUOksDsZzS0pgyR0SeNsf7X09Io6aZyXmbwMw/SEuE165O4Wle
Kx3kto4GHGhWhja2pynL+E6z0JJHqvZl71mqiYnxU53g8pGoZzA7NJvRVfWpwGwkRBf45Iig
sc31wtNEYVXSEjBansar0+3Rup3fwozl1ZmzD6q0Fu3J985JJCmXp7k0v9SnO8lZudTZaZKz
y4VA/wz+DDe1+Qknw+OhKtNQcDuQuC6mB39TnjmXNoF/miS7U4EId6RZ6bMqZOp9zSlO6+eO
hpE8ZMx7CnpOy5hA4iSBcc1Ok2h8tXGOwuQrz1BJvC1+iuSkEehIwNafJKivLu0EWudPOc9A
eXt9+fNiAm0jgMaOk6YYRyJc5CSRWQ2hhq/DDu4KkIs71R/iwr0itvSsehh0vgaDCiKgs5N9
nkKcwoWXCEieOj5DhzWXSNUk6Vs163nlAK/+9V8k91LM/0ti8pvvp+mBMQMCSH/40spP33qE
t16RB94Fwgh3wl2aEV72rwcmrcZIbYbAMGkONYFYYGg3z+hGSNMmvt5NLhA7mcJmhN5Jw2EB
ilfTJEEL7xy1zA93jLyNkNWQ2fVgtc6nCD/54Bi7obKDnGdA+qHKZc4CjTwT713a+dwkuZmC
YLv9+0VCKwfEOKVOHn5f/H8lYnFKInxviRyJWAQkYhGQiMVJiViEJGLhlYiFVyLcoV3WX/hY
fxHg6IWP/Z0XgYsQny9CjG4hWM0X7wM4PJwACqOjACrLAwicd3sXJUBQhCbp4z0brQMIJec9
ehICHSYwRlBWbaxPWBd+aV3MRG/kzdm7m1T3L5XmabW2EKxtMYD7V1Bpw+IpR3Q4QGA+vdbz
ZojSs41wkE6OwsJ8uLhsrrwYUgjbG7MxtnK34DwEXnjhk/jCwrhuj4WYedcWTmn/8OuclKFl
SFbld15kEtownFvjR80TJvb0Qh06aR8L3ieExttdnTj5r9q4cXR7LYKO1yuMijevmyjlyWGm
3W1nybRDsktQ9XHtvztn0135p9QFF1a9oIZG8RKz1LT0VmEaiv42tbl8Y14n4/UK52pniE5l
5F2gVjHQAmt3QjOZzyCExXEnt3naEZ1bLDJRzgPGM/YGISi84+DRB67Kat+Vzi4FMJYAwHOz
9h2VR3JmHMmXBRwo3mR3KnrNnULDa4pM76QByH99FwQS9c67j150As6Q92VAnlNnPTm99F1/
1iR3klNY50KqKmeI8F+Ou/zZC89JFXsRVSb8U1yAw1DZ6qYDNGVGvUBza8mPQTPuZgltbCYq
P8J1M2xMIWKeYyGQF4uWxQm/bWSdeEZbAoJBWJ0l0j+d5amWnBbemdq9+jfHpnB9HR9FbzFH
xcUYQ+77+b3/pa4R3SxQFpVQX4FjUir8LoPA7wvYNXIQ95syJkuaBlj/c+1r0MR20YMFT4j2
wkvqBRfm3bsll6Ji5VrdcHCz/LIZviTav+d2VVpR5ZPrkQhplkq4NHP+MlDwfz3XJkvzJnGY
VKb8l2/NUZm1gIwHbhPlV/gmFRNA7Qtkt66dKh5oJ2/x4vxd49YQxx+dqipTo6slI4WnRs6+
BB0dt4fuOwnOBMCfWTJ/NVRGCkkS7r8GSIm/UaASj4Dneitd6zGiVtRKIzrLsQ/hBlybPFT1
eMML4i+1kOmKB6otcQN+8X81gBKe+hGswsS0Xy2XqW+FlSLAam5OsOGpBejvtVklmR2kK7Lv
xVyB69AVOnSgpRQwp3wqA8Br7nWvgtyZit4RMVZKEJ6LtYd3ku3vD/fbKNk//N6WrI0fVHm4
78C+2qG6LeFu30V4az3WuqhSa8o9BEwEXtIa3RyNN0pyp7oZfGbTfcplYeoN45rnSX/pP33Y
P/2x2W+jx+fNl+1+TBukN6b+19aPoKElGfrBbziMe9JTt1+tCC4FK0BujIWf1yfgR2IaAhEe
GFnJ1+bCrYitYx++uVPVXd3AULuAxUBfzPZbbwzhT2nqve3TK7TfUAg//4JcYVLTWxS8mqqo
vkq3rPMcH3x174kUVl1D3yJ3qhltqCnuae/ifZjiqbyrtDBtn6a4RMaJ41XBc9PVL5YY4gaK
kvolxMm8T0k8UwdgN7/xMyo2znw9wy5MMluAmpQma2sQB4wfXknxcwYfLFXiENwYwfb7kw2K
Z8O0Y5SGOcXzzy6UWKE2FpONCgrgTRq4HIu4Ni0x6694ONzP+RHYvbgzFZTWtFhJc6FqkEsQ
HMPT/nAIttKvYC+n/NmWOjEQniI6zNfUYppfrujtYtZMb//cHCK+Oxz3r0/muxOHX0E7fImO
+83ugF1Fj1hJ+AUW+PCCP3s1RzAHuYnSakmir71S+fL8xw4VS3e3Jvphv/3P68N+C0Nc0h/7
pnx33D5GBafR/0T77aP5htg48QkJSnqrSnucomB75uC1qDzQsaPs+XAMIulm/8U3TJD++WUs
Ez3CCqJis9t82+IeRj9QoYofp3YB5zd0N54OzYSHqU3YxhOnIAkeZ+eH3yHoGM/awp6H8CMF
hbBuMErCE/xqlbTCXKSyA2do036ZzArNsZ+PfXTuDcaBAu/6Numgos3UujlFx79egBuAi377
e3TcvGz/HtHkLbDlj1YtXievypovzWQLs6KMHiaUDR1ay7nGUrIBi5gI6enYSeAMUNf5thcJ
v9HoajXboFwsl6E6RkOgKDr9aO/8x6h7kXOchbZpxdtjC/ee0jmFjefmf8/ZNwqLijv4ZFjA
gC8Hf06sSlanBwYHwHzGzsq+GLh20mEGhKVk7SeNZlOpU5VRvyVvWTaYlWnR/mjK4IRKzAer
OAHXIVQc7SszT+asVlgGrkgarKcn0gGhCF7MIO/mkDnR+5+d1zlFX6RMtH91RecA+EuuANtd
hfJHKiF7OzgchfEsIWacb0NSOK5IEdAeNsXsAEcU+AZcTDo05O2HWvBdAFmCA4AP/noT7ITj
Rwi4susi8Jsb+MUZ2ARwmCF0Jw6uLs1NNZY4UOOEORBVkkplwgXqDPw4UIlrjl+0aQNrewGz
7bWR5hMMoQMAPJPuTAsupev2AhBfY6B3bj4U4O8Hucrp6BOTwu2557Dpgfbw5qM/eHRoAlWq
5hz9X5bD7TdxjPO9jgJLp1fMz9CABTeQB9gdz2mWVnE3y+y6cpY/fpxngA43bO26D02Btv1s
kANLec64cGGVsbh2ohQc+thUOMy8y9H4tzpzRjDGtGOEZMW500r2WJRJQETQWR0nyj7WJAdP
3r2TBTEbKeaQrpTPU0viEEiIGsCnj3kZpDAfFwth8csKa4Y7NblsaNFgVBqTHAvI7OCeui+Z
EKCJc//GJcASYhu/vnXQGJmu7UjVTtBD54q5N6nQaxCTFEcHa5K7khR2Pau5V2MntUwiCiDo
fGgJP/6PsWdrbhvX+a94ztPuzNfd+BLHeegDLcm2Yt0qSr7kRZM6buPZJs7Yzpztv/8AUhde
QOfMbLc1AF5FggAIAqqSXpSJuja1GwXAVSuxDETU0ojiAitDbUqimAjOI+w9nU7wrIu2/gH0
h8P3DxTk+X8Pl91Lj512L4fLfoexOBTyZnUViyBP9Dft2E8pplXw/TzBAelzjeElG6sKTvNP
taKYPZJqr0ajnOOLTC4dR79gUyQgJ3zabO58X9mSlMCwP61IbilHuD3xYZkfGEEtqXo8dDdL
6Ob8xMFylPLBo7cIaUugQrUo2Tqgg8goVMhS3fbGmihmOYiMn5OFXq5XRtOkPIhDx0dNWIHY
z5qCf+ZpksafznVCVwVL3hELRSmLTBd9zz+jy4H/uKRylQzvCtym+ZqKs5iXDsVFJQsC+j5Q
pcEQaHBE55/OEk89EIuCzadLjxfiA35Ktk3SDFSHz+hWn+/edfjo2hKxD1KkHcJEuXfcGrbv
BpEpBwT8wPhyuh85AkFEjjRXXQSaD6URFmeZdmUmYChtmU8hO3yqVVvoLae6OzpWJxRVHSRM
tYUqC/FIdSnhkXqJirg2FKP6jFIgOOzwwoCJAxz/NW5sCGiz+XI+PO97JZ+2xgQc337/jJHn
jyeBaW5x2PPTO7rGEWawdcTsYy14E8GB1ge8HfnDDojzZ+9yBOp97/LSUHVnWVe147IH1xR1
eaAIdT4RB+/t/ePitOmESVbqoWAQUM1mGMbKef0jiVCGMC7iDAourpWWMaN5vSSKGYYZNIlE
38vz/vQL448fMG7tj6edHn6sLp9i8M2r/XhIt/SNoUQHK+nlb5QKVoYKqcyndVejlQSVYpqy
XItk2cBA+19OactDSxItDRKTYBFGGAJWjZPXYchWk2BdOOIwtjR4WYwSPv3RWzJepGu2ZrRe
1FGVyafj3JhTYX9YdTACAPoO5QYicaCehkwLiyHh0h8kLR0SoCSaevHt/R3tJSApVnyz2TCa
49cdAOk7w/hOFfKRqysS30fQ/imSRLgFOrQ3SYDj4SCxBGQUEzmHGNTL2t7Mv+uP6PvbeukP
NzfVtCxcS6aufDxZYsSVa7ubFRjYNk6LYHCFClYE8IqkprzKc9ZBHruiXkmabcCcT/glhRf3
b+6v4EvxF2VHh5PG96q88Gx2wfxNNLw6q17Mhjc3NyRFHocjoV5bDGfxdHoWtyHh32mvsec2
5xysdyVEufiJ/9cfUsheK1oJcI840taFLAnChrG7DIKcra9ga0XqehWAjV12u7qa3HNs8lKO
V5n6OYsD8gLLe3k6Pe3w8Lbu0YpCybOyUqSGRoUWcYgiER6Iq5QNgTKTaxsGdB0Yg+v5mgcd
xrW7n1RZsdVs/lEwZ95WgJ1TwyL0XpSX9DnNWpNqzmlxXzy5rTgt0MH5J6NZdmpcsFoCyL5a
2J8OT78osaXu4WRwawfbTI5vXwTiLIsLuYuQquo6ShDmMBrGtZngnpdsHDkoJEW9HB8KNscK
/wfST8kciniNnvGoirLPKhHBu0tXbKY4rGSyBVrEg5V1JWJ+Prwf0+eXCKUmvCLoxeHBn8z+
2uHAoz4TgskRZrSyyjOHQrwg/bGyjOvaCOEl26z3IhPkTbDdjPd2vw7y5tnuN9bkRSFa55ci
RgDdeEMT+TIkJlV+numuWm3zdR6r4+lsXkKDlgSdO+7+scVwjIHVv51MoHZp81XViVoLRDk4
ccXEUvSKp+dnEWgdtplo7fyXNgVh4hU5bQnBMbl8rda0m7U4jyu2cqSZEVgQKB1yjMTzEqQz
WppcrGOHBIIWv5jR41jjqxI/pdYL5xi6k/NQBkjuViin1GyQCBlJjgjr68cfvy6HHx9vOxHm
vta4CEa5KDB2PA+9Idn7eOaDPBRnjji4iI6L8fD+zonm8e0N/bnYdHN7c2PJGXrpLcY3dqJB
nmPxcHi7qQruMZ9mBHkwLyPn/WfuXelB4IdMLAnqVJ+fnt5fDjtyc/u5zb+Yl/X+YB/Ph2PP
O7aRuP+kE8ax2O9Fh++np9Pv3un4cTm87VuT9Oz09Lrvff/48QMkCt+UKGZaVpTWUw6GQmk3
s2kTvr6TCgCWpIWMgKeQwZ8wZvNgCqeh1sQU02QE4TypU9KRcwlUwgYi3enoLQo0RRiJBgrj
Jsce+EsjiloWeKjGiscNsHIVOB4FAPK6ugkEvO/3h6BxufDhNK7mm2J065CpgQSDYpcONoHT
c9UKCwTCYs4XgYOBYSdD9DYlsXi1FGHevyryfOeahrV4Pv4SPlHvv55+13NrnxHS/csSNzUw
hrEvY5BaJzc0Pk/X/Ovgtv1sOcjP0ldOqbkbno2GkxiT4ODdd8xymmtTxfK0cMXbjFI9AjP+
RleHcgPLN6FNtQrNas761NNThcSLymIw0FJ6cbw8tHUt2LDWxC9CzRMSfqLLPQiMW+E9jXE1
KFUx9PH1YCf3E9XUHqm2kI2ZAuD8xu5YWw0LshHeZpnVMS8vN3RXpAXEKlBiUAlHiWkQLdWr
VYR5cOrmWxMWwq+tWbcnOLmjbm8rzLhmGZixeZrkoeMmDkmCmFcz2tdWoKPAuN9SkY8YSdv6
BvE0dGhTAj/LaWEbkVCf26okCLbuoaxB60hpDUY0vM2tHaMRhHhb58Y61CfEPbCp47IQscU6
TBaM2qlyyAkokfNCOL5o5SJPyHPOeqMgSVekdyIi03lIrekGXvkP7oobGviR0RPakjjWDuLz
MgYxL2P+4BrV/H50cw2/hsMiurpG4UAPPWEuvEKynUWMO/gKPjwVO0XfiPJmMp0VBjjFkIX2
whcXPNdXb1I41DbAwVEW0DY2xGYsQQk9Sq/srAxf6G0T+ngXBMBYIoeXnsBHDB0YEiOcvk6T
O5+qIJqz8Nowrt1lCnwWBL7T2Cgo0JfkGhYWC5wBDiFI0JRJFjnsBWIxuHRr5CFoHAZVw73Z
xcXZQ7q92kQRruhjWCDTjAeO53MCv8hLXshHWU6iEg/LKuO0SoQUmzCJ3Z1AR7OrQ3jc+nA8
XuGmHPiacDqg9V9xXEZk0tYSdMp04YUVytAg6phJohFfC386UGTuwRw8C0+7KjKuDuRVGMAo
XxmEZy+/z5hFuxc9/UaDp61yJmkmWtx4QUhflCF2znyXvxi+wqdVPSxYRlnotGmVa3pG45iu
MIYj3nk1kgRrOEd8uiXmYT7hUL56pe1r8P8knLKE0sty0Mu1lHoIEPExddDCK1K+pYH1bf7X
/5wuuy4XNRIAsoBVopeqgUapTlEuvCueyIjFVyS22gsY/cpUKREmxax2iv5tweu0WibYeKek
wqsyDDBrFa1iiQHkKyuBd2tcxJ4aKxqNiA4wmsAcpdokYDrO6onP+4PJ+GpngeS2T9tPVJJb
mlcpJOPJbR3M/TPKuxF9ZdKRDEY3DstuTcKLZf+uYJOrRPFoUnwyeiQZ0u/jVZJb+v6sJeHx
ePDJoKbfRpOb6yR5dus5TFkNyWp4M7AvHI5vXzAipb4YjJK19qUFZKhRswL+ddO360WNjO/f
8J2OY6H5MatdZ63CgAKtWMmO1Gmj6AqDzr00Xys3fsizyHHlXjoeDYuEYNLoT/NLJAhTYLhJ
afU1PuxOx/Pxx6W3+P2+P31Z9X5+7M8X8tKmYM6XKos15h1EozbN61kYTVPHnWmKKQFdVpN8
/3q87PHVFLnbxT0ycjO74Pvr+SdZJot5Mydkh4TJYB0SV7Qc2vmDi5T0vfSt570c3v/snZt0
f8bDLfb66/gTwPxoMbHp6fj0vDu+UrjDX/GGgn/7ePoFRcwySq+9ShfjBXaDSX//dRXaoOfX
plp5dDbCDB3tV7Pc4cEXbNAb2XW4pw6rUeiY9mxN3Evl33o7mGXbWMPyuAL1CiM6Vkn+ta/U
n4kMBQ4pRVxSKB7RtGErttdTttj2+Mf3s/j66hw2z42RgLQOenG1TBOGEtTASYU3PdmGVYNJ
EuN1GS0zaVRYH02F6rnncMaKPVpMy5nNyNjb8+l4eFZHy9AVnzR3+2yjOYSTEstije7gO/SV
IzkMrUIJ39/K8VxJPCUl93Ho4Dg8CmNjfeiyheVKsAhAe5oGapAO8WxxwXJfPHL/7fZGkOZ1
zCMo145qTefI/UQOSXVTDSpH7hPADQ1chxlVqqgnAOipNEM/bKjTaAOp8cor3IA4TQt1DRUP
vNL5PkYQBYl43eRMAIw0rpvdh6mv9Q1/O4kxlMHUCNWQByFo1oDRn/+1YBEf38ELahLxLZ25
uZQGqg2+WaRGYbX/8On8Pnw2t0jgVgtE8et5Bs0+IUQEKSYr3HzaY6RwOD0gKq0zEHu5Q7lG
Itgu9CrZXB3tfMbNbVFjMFPQQA7UgFTpwJsS4PZ1mxLUvW1IUsl3gjHjyyilO6TSkf2aFvai
bGCfzHNLJtZu95rsOnFeJpghB+iEHkazEEntnmeJB104cHzorrlgJh7OzehuJWFkf7KOaQ9E
JTSO41lC7/523lROh4LjjOsMTsLql54pac9BObx5/NlVJ5LtFCC8OPBQacfuusU14+a9rm8C
QgkQy0+pj5l0Moy4/rON0oRrIRcRkpXhZjmAa0LcXy4pXVK4mKvE1qlzujKYM3ZF62YSR3nw
ibq8QvlMrCzSGR9pG1XCNNBMnFkKwEPn4G4Pw4oD/cjYVh20jdVYwV8UsyAoWbRmW+gF5qVe
a0G1OuIw8QNamFCINvCFxZgsycJ7qpNUKIvceqcr0SK+wd/+yhcygyUyhDy9H49vtLP+IY1C
Nb/SIxCp+NKfyQmT2mnK/56x4u+koFuYYW4p5QPEHEpokJVJgr+7GIx+gBmav46GdxQ+TL0F
vhYovv7ncD5OJrf3X/pqhCCFtCxmtJkjKSzuIQW48/7j+SiSNlvD6sJMqIBl/dJVhaFjjLpy
BVAknY5T4K5qPAiB8hZh5OeBYgleBnmiNmWY4ZooTZ3VVQRpun4mSBqX/AGy9syvvDxgam4x
+Zexw9BVXPA2NEoGsdKvVOSfsA4t5luz3WBmRt2BYIw0CPrIubAgKH61Rnn4jdZ9owMd9LNz
M3CfKlM3yi7VzF/OYo0Xid/yUNHylvFvJeMLlbSByFPESqOuoyUjIjrQkvl43Z2hW+88oiuq
KcRtH631UJR1qvTrBVyLriV41MzpLTh6HJHQlBzA5vF6Lx65IyRXSzESUSQwmAQGk7pOG8TT
wPfJhMHdt6kjdcrPJyNUDRWz2sa1buIQk5rrm05CqimuN3FxVPXH07CQJ4v6zi2NzU2RGYBv
yWZkg8bWxq2BV24W6rZoKwIvDOe9jputtMZLq2UJkZERaFsm1a+Gu9fOrySPSmRb2u/VwPg9
1N7sCojJM1Sklr0AlKq1rpFLmqpPFM8x8kwy4yY5CjG1p7+fkEE3ayI8KYIIibQhaEkNuW+P
yCeGZOCpxBVz8Tggw9cVyooT7Mz4Wel5KniTHLbbz2WSZ575u5qraVxqWD2hzZxlGOcACatl
Pr3VQvZIeveCFWEiaVYd6isQfwv1mF7cAr0O2LLK1iLziJuqzDzmeFIu8BZ31NFXBiPQ/0ML
PJ4O+9TyA1mLmYe1iyclWizLiDdSliaGKehGjqtAjtMLtpg7wLzSmLtbB2Zye+PEDJwYd22u
HkzGznbGfSfG2YPx0IkZOTHOXo/HTsy9A3M/dJW5d87o/dA1nvuRq53JnTEe0CVwdVQTR4H+
wNk+oIypZtwLQ7r+vr7IGvCAph7SYEffb2nwmAbf0eB7R78dXek7+tI3OrNMw0mVE7BSh2E0
ejiv1XAyDdgLIj0HVwtPiqBUIzO1mDxlRUjWtc3DKKJqm7OAhudBsLTBIfSKJT6BSEot/Zw6
NrJLRZkvQy0HLSBQN+wgfqRHDouIwGBCQ1zuT2/7X72Xp90/MmyzgL6fDm+Xf4TbwfPr/vyT
uroVNhaZDZrkxNL9OUrnImpdy11bHVhqPwTFqHEPf30HvfXL5fC67+1e9rt/zqJDOwk/KX1q
1JZEZLBBgw9UloEKAcqfco7X+LjkdZJYxeiEntui5Nf+zWCk3sDkIQZxiEHKix1+Pgm+w0f8
NI1okitWUZlxhrcdMspwGXEWlVSRM4YW4g0iOQVpElERwYQXJsqs+TfVyNcCW2uDnK6vN//2
Kar6xbnVYSnA2dfq+9fj6XfP33//+PnTCBAueGOwKdDB1nFjIkiyFMPOOcJuSfu0uGUVUQgV
pd8TvmacJV66qp+DCkFNWn+wR73ouPvn410usMXT2099pcM+9GA6q5S2m2r4asWiEmZNR9Y5
0wFsTBcilkGQUU9QsFPdjPX+OL8f3sTDtv/rvX5c9v/u4R/7y+6vv/5Swn+u17DAi2ADHyia
FTKvQNumWBcgWmFIPpGUnXhU2axLjJxaRwcs56sgn6ZcfX1hY6SXgVfSH9mPWcUyIsBkIwWX
Cc6FsNTDZAjnDMVChDGuZco77YW3gOsgVqRx6I1H6gQ0KOFugsH6xpWOEfUsgo2IrG3ULrI1
Nm+JDOQSsEW6MaCCNc4MoJlWXQDLUn8cIYBoQcWMXMQsCXyO8rmRrlsOQMtMLudsGZtNcvE6
Jdua/VPz/c5AC8ceV9Mg8Yzk04K6jWZuTJY0FRotiuCE1rTCgeuJAAjmnGKoXfWOCBYabC4M
K4nP5/LSfbEqI+A72PSUu5IJgNKaMSNQdHNmsDza1mdds8b5fvdxOlx+2yeQGI16D9FFxQQU
riOHLa4uS3VA3q0EfjNVbSH4XfmY6iyQ7yVc7+flhSpswIALdw9Yz57rofaVy9cGSZ9iyC3w
8j9IoKe4xHCFibD1HtMsxBbRFVQ1gwrwMZlmH5MLB2nwkd+V6P/yGOsmgHkq/9KxGJW/Rm0w
YBzq/NzkHHqsSgmDI8dT95KEbtLcBGXfaEYEYkqqJE6Rselb/4nT7/fLEWSe0753PPVe9r/e
1WQDkhimeQ6sVTnxVPDAhoPIYTYogDbpNFp6YbZQw1eaGLuQYEMU0CbN1UQpHYwkbAVEq+vO
njBX75dZZlMv1eBiTQ1oGia6w5lF6i8sUOARwDrMrlVnDbcbKzkxgiZYrx9yIdWKG26r6HzW
H0ziMrKKY6oFEmg3j7bHb2VQBhZG/GUvpdgBZ2WxCNRgaDW8Poqlh9XH5WX/djnsRDT74G2H
GwCflf/3cHnpsfP5uDsIlP90ebI2gqdmeGmmgIB5Cwb/DW6yNNr2hzeaza3dD/MQXaZpK5RO
4zBVKUSDW9r5uJmxNC/5eES/5lVpoLEbStuSJDz4FlqsBEPjM5CIV80UT0Uohtfjs5bzo56Y
qf15vNnUhhX2ivQKTrRtl43ytQXLqIY3RIVw6K1zIUbVMYLOL66haFmcGy5EATdU4ytJKXWE
w8/9+WK3kHvDgRZNSEW4PxOgi/6NH87s7apLcM3kdKvUWBL+iIARdCEsAdCw49AeZx77sKhI
sGox7MCD2zEFHg5sapEskABSVQD4tj+gwEMbGNuwYp737+3y60zWKk/Tw/uL5hHfblGbcwIM
lDObhyXlNLSXJcs9+1OAELGehcQHbRDNHYK1k1gcRFFoHzEYFdpdiBf2p0eoPdl+YA9hZgRk
bzbcgj0S4gJnEWfEJ284q10gCIhagjzTMv+1H9ieTZ4FalTw9uywZ6lYp+S01/BuAls702l/
PmvJn9t5MgKJNizsMbVgk5G9+vDCl4AttLcXNdy8zpXq9NPb8/G1l3y8ft+fZEosI011uy4x
qUZGyVN+Pq3VaRIjWKK5+iWGkuMEBtk/hbBaeAgxXkCAzuWqkKwINmgUcCIqkh+2WO4S71oK
aj5aZC0Hmx9iQYd6A5k9xrAZUmkVDwNtZ6X96YJPH0BCOYugqufDz7cnEbtbWDANm4i8zMUc
iBgvg7dKom0JsqOz1FVIHULVLUBrx8xluWqtaVzyQfdLPNSrMJOR7nankkRB4sBiKNayCNWr
s9bd3wtb520DZYA9jIPjwcpQP43XH+sU9hEJFRVlpZcaavIq/CTMPjU8Cr1gup3o57WCoZ+Z
1SQsX7uCL0oKmHYX1lnxHSEjROG0liu0lelNCNrNpt4fnQODMOcps0CUAkbVxhPuJgmh0hFG
h6MrC7qCR5ojlYBa3BHYIlEzQpWau2v1xxFJDeyRhpO1INskyAWYGs/mEcFdefm72kzGFkw8
G8ls2pCNRxaQ5TEFKxZlPLUQGB/YrnfqPVgwfSV3A6rmj6GypRTEFBADEhM9xoxEbB4d9KkD
rgy/CEBMD/BFNwWrlro9tYVPYxI84wqccYxuzjBZBUxlzjRTkXgpEsQ6yFcHyOeRNEApg/im
poOI0FHB5laNAVlZqXlZe6x1PCV6xEC1GjNJc///54l9m5KLC46Dq4MCwadJY5umCfAELSKD
W+gPPv4C2JUMQT6Hxs3fLwRpjz1i1ShQHOsSb5B6iwoLpJkviAhy6RsM2jHljxRSwdCxa4QA
ZEwcqagFAPnGzbbYugAA

--zhXaljGHf11kAtnf--

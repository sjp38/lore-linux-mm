Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 537816B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 02:40:49 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x23-v6so6253893pln.11
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 23:40:49 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b4-v6si9932015pgw.50.2018.06.29.23.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 23:40:47 -0700 (PDT)
Date: Sat, 30 Jun 2018 14:40:20 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v3] add param that allows bootline control of hardened
 usercopy
Message-ID: <201806301317.Mgx3cTTx%fengguang.wu@intel.com>
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: kbuild-all@01.org, keescook@chromium.org, labbott@redhat.com, pabeni@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Chris,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.18-rc2 next-20180629]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Chris-von-Recklinghausen/add-param-that-allows-bootline-control-of-hardened-usercopy/20180627-204733
config: m68k-sun3_defconfig (attached as .config)
compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

   WARNING: unmet direct dependencies detected for NEED_MULTIPLE_NODES
   Depends on DISCONTIGMEM || NUMA
   Selected by
   - SINGLE_MEMORY_CHUNK && MMU
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
>> include/linux/jump_label.h:194:9: error: implicit declaration of function 'atomic_read'; did you mean
   return atomic_read(&key->enabled);
   ^~~~~~~~~~~
   __atomic_load
   include/linux/jump_label.h: In function 'static_key_slow_inc':
>> include/linux/jump_label.h:221:2: error: implicit declaration of function 'atomic_inc'; did you mean
   atomic_inc(&key->enabled);
   ^~~~~~~~~~
   __atomic_load
   include/linux/jump_label.h: In function 'static_key_slow_dec':
>> include/linux/jump_label.h:227:2: error: implicit declaration of function 'atomic_dec'; did you mean
   atomic_dec(&key->enabled);
   ^~~~~~~~~~
   __atomic_clear
   include/linux/jump_label.h: In function 'static_key_enable':
>> include/linux/jump_label.h:254:2: error: implicit declaration of function 'atomic_set'; did you mean
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
   static inline void atomic_inc(atomic_t
   ^~~~~~~~~~
   arch/m68k/include/asm/atomic.h:125:20: error: static declaration of 'atomic_inc' follows non-static declaration
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
   static inline void atomic_dec(atomic_t
   ^~~~~~~~~~
   arch/m68k/include/asm/atomic.h:130:20: error: static declaration of 'atomic_dec' follows non-static declaration
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
   Makefile Module.symvers System.map arch block built-in.a certs crypto drivers firmware fs include init ipc kernel lib mm modules.builtin modules.order net scripts security sound source usr virt vmlinux vmlinux.gz vmlinux.o Error 1
   Target '__build' not remade because of errors.
   Makefile Module.symvers System.map arch block built-in.a certs crypto drivers firmware fs include init ipc kernel lib mm modules.builtin modules.order net scripts security sound source usr virt vmlinux vmlinux.gz vmlinux.o Error 2
   Target 'prepare' not remade because of errors.
   make: Makefile Module.symvers System.map arch block built-in.a certs crypto drivers firmware fs include init ipc kernel lib mm modules.builtin modules.order net scripts security sound source usr virt vmlinux vmlinux.gz vmlinux.o Error 2

vim +/atomic_read +194 include/linux/jump_label.h

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

--ZGiS0Q5IWpPtfppv
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICCMNN1sAAy5jb25maWcAlDzbchs3su/5iimn6lRSu87KksN19pQeQAyGxHJuBjCU5Jcp
WqYdVSRKS1K5/P3pxtyAmQa5pyoVi92Ne9+Bnu+/+z5ir8fnp83x4X7z+PhX9G272+43x+2X
6OvD4/Z/o7iI8sJEIpbmJyBOH3avf/7jafbht+j9T+8+/HTxdn9/Ga22+932MeLPu68P316h
+cPz7rvvv4P/vgfg0wv0tP9XhK3ePmIHb7/tXt9+u7+Pfoi3nx82u+ifP11CV+/e/dj8BQ15
kSdyUWezD6vrv7pfvKzqOfwr8liyfICrGy2yeiFyoSSvdSnztOBOuw6zvBFysTRTBGepnCtm
RB2LlN0NBEZmok6Lm1oJPUDzopZFWShTZ6z0wHHGht+filz4kOWn63cXF92vcmHYPIX+xVqk
+vqyXyavpa4XnDsTBdhaKC2L/PqfF5dDHzxl+aJH9WCpPtY3hcI9sKewsMf6GB22x9eXYXvn
qliJvC7yWmfOQmQuDWzyumZqUacyk+b66hLPsh2zyEoJ8zZCm+jhEO2ej9hx1xr2nqXdjN68
Pbzurt5QuJpVphgGjUXCqtTUy0KbnGXi+s0Pu+fd9se+rb5xN1vf6bUs+QSA/3KTDvCy0PK2
zj5WohI0dNKEq0LrOhNZoe5qZgzjywFZaQHMAr/7/WAVSIe7EXbL4Qiiw+vnw1+H4/Zp2PKO
5fCE9LK4GTpmii+xdzh6YZDxiiTRwnRHCMz/D7M5/BYdH5620Wb3JTocN8dDtLm/f37dHR92
34ZBjOQrKy2M86LKjcwXwzhzHdelKriANQLehDH1+spdp2F6pQ0zerJWxatIT9cK497VgHM7
gZ+1uC2FolhHN8Rucz1qL1fNHyTjwRKqBLZVJub63aw/ayVzs6o1S8SY5srh6oUqqlIT/SI3
6pJxqwJ6+sroOvfIhzkCGwZQcL4qhCtlHELlwoRQmi9FbGXJLoCmudOJBgkrleCg5WKSSKHq
I5Y/T1fQdG21gop9LaFYBh3rolIcBLYXVRXXi0/SkVYAzAFw6UHST65uBMDtpxG+GP1+7x4A
qMSiBDmRn0SdFKoGnoJ/MpZzQaxiTK3hD095eBqA5aCfZF7ErtpfsrWoKxm/mzkiUybunIKc
PWqWgaaTyAvOFEDqM5AwOxeWpt7kcJPH4GTJ8jid6DTUHMqZdcP9zowrRxeINAF1rpxO5kzD
BlXeQJURt6OfwKyjjWnAPCtv+dIdoSy8tchFztIkdqUc5usCwBrmxgXoJahi52ykwxYsXkst
us1xlg1N5kwp6W7xCknuMj2FNMtGCTByLbzjnW48npu1VXaSw9lncxHHvnBZ7di6R+V2//V5
/7TZ3W8j8ft2B7qbgRbnqL23+8OgNtdZswe11d3eYaLpZQbstnOgOmWeOdJpNad0K5DBrqiF
6Eyt3wiwiRJg27SpFXBWkdFKShWJTMGgUDKmmF6O+GklbgUfwaylu2GwQtSUJVOw953DMPBt
Wi1kbt0B8ITefPvb33r1ArK8ZCARYJhXMB8juAGJBpEVI57MirgZTJeCy0Q67gKgqhRsLRym
lQI8+5PYAVmkMfKxrqDXPL6aIBg3zUoc1ZrYs7SCNeGPBS/Wbz9vDuB0/9awysv+Gdxvz6Sj
s4kS5ioky7Q6Q+a8GM3cHb0BodbjaABZTBxdS1PliA82btAkXwBde4S0mWr7AXPeu3/+Vkwo
fRs/RqMkgFNOD2aUzGCycHpxvUL5Js2aFyOk85glztaC0dNcSzg68BG18TFoDud6QQIb53Bi
O41YKGnu3K3tkBgn0JuKFDyLQdxEIyYqSHYzN0EcbkNRsinnlZv98QGjtcj89bJ1VBAMZqSx
pxSv0aJ6PMFAnPOBhhyXgSk6TVHohKboeshAlAYKR30YpiSFyBgnwTouNIVAfzeWegW6z5Xv
DDyb21pXc6KJLlIYXNe3H2ZUjxW0vGFKeN32K07j7Mye6IU8QwF6W4W2tuukyr259W1XDNyj
M/2LJDADJ8yafaD7d1h12r4JiopI3/+6/fL66Fk8WTRebF4UbhjaQmPBbL/XT2MMTz5OA8gG
2E+qA2PfxHo6dNvl9Zv7r//pDU328cQkHOTqbg5+xmR6c5hJD2Q6f+eQ5HanMFdhtSrEaxAR
us61xSsYtcWfwpFtb0DfiFBjF+m3zrLK+4Hs5Ng4a88dESoKCNOSwsaNXahaPm6O6Or06YYG
un++3x4Oz3urbPwcD0+Z1tY8O1mGNE6konx5aHFxedGP1verX7b3D18f7qPiBZXaoYmbh1ES
iIhFVtH6qtVzFMuDtwMWp80H8GWVj3JS6IywOEZzVPeBYuctl1U30Wxz/+vDbtvr2mFs1HT0
rFDV0WaQcboF+tsFiVpngoQvy6uLC1odwdHfkpiP7y9ozXPVrXb+eoj068vL8/7YcUDrCCfb
zfF175qbBPxuz8dHQI3hF+76KMsmQLJs/FTCoYxCNF2m0tSlsWwNR6Ov3/t5q8Y3o9wB8M+4
4z+uJXhcpoBwyfOlVjo7oUQymCmaD8sN1+8vfpl5s4bY0PLLylkpTwXwHQN94Q6TqCI3mPAi
BvtUFkUKmqQn/jSvaPfh01UCQkSjrNtY0DwkIawEJQ6RAgT4fDVy9odQQChczSQl1BMsqrKe
i5wvM6ZWE1sg/tzevx43nx+3Ntcc2eDo6HDFHBRLZtD/9gLWNpZwjhXtbZWV/TGgx74E7QiO
JnXSTbeaK1l6MVCLQN4jmtmAghWV6wo2DSzwaQTMpOYDEOeIU3TZ2Hg/QDEvUIF04pNvj388
73+DGCB67rVZ753xldu8+Q0+B1sMQ6Ir4jsmIwID4bLDRfATvVFJZk9uE+XwLP6qiyRpYwUX
ytJF4e6pBVYhx9ViwdGqQWlJTiWfLAWoR0zOT/pFzoNwVXLqmC0FxJcg9MOacaNXwvPCW1A3
CD3PuATPDzeZGkk2Z+mk/xr9xJmmfXIg6MxNrYB5/N0ZiCyubmyjm3gr6zIvx7/reMmnQLTP
U6hiqhxxXylH2yTLBcoV2MvbMaI2VZ6LlKAfQPouB64vVtK7OLF0ayP9plVMd5kU1QQwDO/0
iydQs6XrXgFA6HIK6fnWx4wZxQItC40nZjEksOFVNFqgNnONF0RhitMdzIUYt/WFt5kFLykw
bicBVuymAw+c2PUMB62NKu5IfsVx4M+TTlJPw6u5m2fpdHKHBwf79fPD/Ru/9yz+WZM5feCW
mbMO+NVKDDicIvGlrsPV6JAGBA9omjQwqo06JnMhuCmzCTvNpvw0CzPUbOAof/RMlrPAOmuZ
snEvQRacBaBnmXB2hgtnUzb02MXF2+1u0+os4FjZlXkibyFamsneAKyeKfJIEJ1DUM2tx2fu
SuEqtTWxGwj0NJKFeCqlgwyNR2fVeZn2njZ014OEdiPCeC0Wszq9aYY5Q7YMefaw93ilC1R8
7E85KrI0ZWsxkrGZs63L5Z1NuYPtzEo6jQukiUyNmznvQW4+qHN4lIzBVRxaPXU3//stujHg
3B23+8nrgEnPgwM0QcFfELWuPGPQohIIntK7dhJU25ZgbPH8npuLUKL7Dt9cH58gSAtH3+Z4
q5Ln1nv2oHj9CGohK/IJGDoC94saAruy6WN6gBq5wVmbi8LUohe/eFiM2ZPAhaNLZ28j/gs6
e2ld0T7PhNAyIMV9LqFNoU0WYHDmEJvFnId66Eg8DeAiNHf9IhcD5hOCSBHYUZaxPGaBk0hM
GcAsry6vAiipeAAzV2BX0IsM4IFF5rLAa+gAgc6z0ITKMjhXzXIRQslQI9OsfXROrXQEOaKn
oHhnoMuZvwU5ZgcgonbVUAsOn+GAnZw9ooiDRfD4SBE2PjGEjXcGYYZqDIGgVIIbShuB0wwz
vL3zGhU68X43xogAdYHIBN6qFgcD21dlC+FpIVN7KjDBSLi4mbo3iNHoT86NEmIKXzK9nELn
0mAaxx+vud/02cZYprKvjkhmMGNVa9onSh4oY/qjD7H77oNGbGXqYv5v9Co92FjzW1Bh2Lj3
f4vx9jWw5lRG68ZbXB823bVEzieArjNvv5rIlJacuCqnlgXahODJTUzDYewpvOGQ5hXbeJkO
jjJqtz0bW2fh1iaCDtH989Pnh932S/T0jJcEB8pRuDWNySN7tdxzAq3tLL0xj5v9t+0xNJRh
agH8y5eCr3SVBbrtqDrP6zTV6Sl2VKRDMuBjzcvTFMv0DP78JDAVaF9onCbzRZIgODGSL4VE
21yMVAdFk5ydQp4EnTiHqBg7bQQR5omEPjPrXs+fpDLizITM2CBQNDDlc93wMtP6LA3Ectoo
a8o8EXnaHO9/PSGNhi9tztsGZvQgDRG+lzqF52mlTZDbWhpwoEUe2tiOJs/nd0aEljxQNbe0
Z6lGJoamOsHlA1HHYG5oNqErq1OB2UCILvDJEUFj23eBp4nCqqQhEDw/jden26N1O7+FS5GW
Z84+qNIaNJHvnZIoli9Oc2l6aU53kop8YZanSc4uFwL9M/gz3NTkJ7wMD0GVJ6HgtifxXUwC
f5OfOZcmgX+aZHmnAxHuQLMyZ1XI2PuaUpzWzy2NYGnImHcU/JyWsYHESQLrmp0mMXi1cY7C
5ivPUCl85n2K5KQRaEnA1p8kqK4u3QRa6095v4Hy9vry59kI2kQAtRsnjTGeRPjIUSKz7EMN
qsMW7guQjzvVH+LCvSI2J1bdDzpdg0UFEdDZyT5PIU7hwksEpEw8n6HF2tefepT0Lev19Mm/
LP/1XyT3Esz/K2bzm+/H6YEhAwJIOnxp5KdrPcAbr4iAt4Ewwr1wly+ZzLvrgVGrIVKbIDBM
mkJtIBYY2s8z+hHSuAnVu80FYidj2ISQnDQcFqBkOU4SNPDWUVvScM/IuwhV9pldAmtMOkbQ
5L1j7IfKHnKaAemGwjc4gUbExDuXdjo3xW7GINhuer9YaOWAGKbUysPvs/+vRMxOSQR1S+RJ
xCwgEbOARMxOSsQsJBEzUiJmpET4Q/usP6NYfxbg6BnF/t5F4CzE57MQozsIUcnZ+wAODyeA
wugogFqmAQTOu3mLEiDIQpOkeM9FmwBCq2mPREKgxQTGCMqqi6WEdUZL62wiegNvTu5uEtNd
Kk3Tak0FV9OiB3dXUEkt5mOOaHGAwHx6ZabNEGUmG+EhvRyFg/lwcVlfkRiWFa435mJc5e7A
ZQg8I+Gj+MLB+G6Pg5h41w5OG3r4dcry0DKUKNM7EhmHNgznVtOoacLEnV6oQy/t48C7hNDw
uqsVJ/qpjR9HN88i+PC8wqp4e93EuYwPE+3uOku2HZJdgqqfV/TbOZfuip5SG1w4hX4GGs0X
mKXmOVk+aSm6Z9D28Y29TsbnFV6xT4hOL9m7QJFhoAUW3YRmMp1BCIvjjl7zNCN6r1hUrL0f
GM+4G4Sg8I6DRx94MWuoJ51tCmB4uw+/6zV1VITkTDhSLjI4UHyC7pXi2jeFltc0G79JAxD9
ihcEEvXOu48kOgZniLwMSFPurSfll1TRhWGpl5zCAhVWlqlABP047vJnEp6yck4iymVBT3EG
DkPpqpsWUOdLTgLtqyUag2bczxK62GVR0gjfzXAxWTGXKVbwkFi0LF747SKrmBhtAQgBYfUy
VvR0FqdaSp6RM3V7pTfHpfB9HYqis5iD4hJCIPf9/J6+1LWiuwzUM8WcqkyMc43fVyjwwwBu
cRvE/bb+yJGmHtb9uaYa1HO3ls+Bx8yQ8JyT4MzevTtyWZQiX+sbCW4WLZvhR6LdPbev0rIy
HT2PREi90IVPM+UvCwX/l3g2mdubxOF5v6Yf39qjsmsBGQ+8Jkqv8CYVE0DNBbJfkM61DLRT
t/hw/q72i3/nH71yKFtca5RgGVHc5j6Cjo7bQ/uBA28C4M8sBF3GtGSZYrGknwFyRjcKlNAx
8FxvlW89BtSKO2lEbznuIdyAa5OGyhVvZMboMguVrGSgTBI34Be63J8zmdAIUWJimlbLeUKt
sNQMWM3PCdYycQDduzanlrKFtNXxnZhrcB3aQocWtFAFzCkdywDwmv/cK2N3thR3QAyVEkym
xZrgnXj7+8P9Nor3D783tWbDh1Ae7lswVShUNbXXzV0EWeuxNlmZOFPuIGAi8JHW4OYYfFGS
emXJ4DPb7hOpMlsoOK9kGneP/pOH/dMfm/02enzefNnunQKZG1u46+pH0NCK9f3gxxeGPemo
m89NBJeCFSA31sJP6xPw4y41gwgPjKySa/vgtpg7x95/O6es2rqBvnYBS3++2O13bgzhn9wW
arunlxnaUBQ0/4JcYVKTrOZdjVVUV16bV2mKP6iC9VgVTl1D1yL1yhBdqC3uad7ifRjjubor
TWHbPo1xsZrHnlcFv+u28DDHEDdQlNQtYR5P+1SMmDoA2/kN3z9xcfazF25hkt0C1KQ8XjuD
eGD8YkqC3yH44KgSj+DGCjbtT9YonrUwnlHq5zSffi8hx0K1oXRsUFAAb1MPkzbZw+F+ynPA
0tmdLW90hhY5TwtdgeyBcFi+pUMe2C5aiV6OebApZxIgIFl0mM67wdS/XPHb2aSZ2f65OURy
dzjuX5/sRyEOv4IG+BId95vdAbuKHrFo8Ass8OEF/+xUGcM84yZKygWLvnaK48vzHztUHu37
meiH/fY/rw/7LQxxyX/smsrdcfsYZZJH/xPtt4/2e18Hv1ZvIEFpbtRlh9Mc7MsUvC5KAjp0
tHw+HINIvtl/oYYJ0j+/DHWfR1hBlG12m29b3MPoB17o7Mex7sf59d0Np8OXBcG4NjSTsVd0
BD8n54cfCWgZz9nCPtDVEl/KD3KqmIzxk1LKCWWRyg/PsdXHLt4mw2ugwNe7ddIrXTuRdgbR
8a8XOHvgmd/+Hh03L9u/Rzx+C0z4o1Nd10qgdmbHl6qBOXFDByu0C+1bq6kO0qoGGxcXiujY
S8n0UN+ddhcJf6MZNXqyQWmxWIQqEy2B5ujGowWjD810AnYYHZguZXtE4zET3iBCs5X2/8Tx
1hpLhFv4aJqAAZcM/jmxFFWeHhjsuP2KnJNEsXDjZbUsCCvCmk8KTaYySZ50yCq/ork0puMg
iyt0bL8RJRkY/VB1M1XdHU9ZKnNMUxbXWMLOlAdCwbqYQN5NIVOi9z97FzFZV17MDL26rDXd
dLEUYNtHTHSMEbKUvauQWZ8Qor3pNsSZ50RkAS3hUoTO1A6TyGLUoSVvvo2CWXy2ANONP+hK
EexEYu2/1G5FA37mAj/yApsAri4E3czDVbl9YyZiD2rdJw+ic1bqZeEDzRI8MFB9a4kfkWlC
YncBk+11kfarB6EDALxQ/kwzqZTvsAIQLyDQr7aV/nQ/yFVeR5+EKvyeOw4bH2gHrz/SYZ9H
E6gvtedIf8wNt99GIN4nMjIsel4JmqEBCw6cDLA7ntMkIeJvlt117S1/+B5OD+3fxroVG4YD
bfOlHg+WyFTIwoeVVkO5KU5wxee2NmHiMw4mvVGTE4IhGh1iGydCHdegz4s8DogIuqDDRMXH
iqXgg/uvqSDaYtkU0hbhEVUgHoECfx+88bnMgxT2e14hLH4TYS1wp0bPBB0ajCfnLMXSLzcs
5/71EAIM817O+ARY/Ovi17ceGmPKtRtjuql16FwL/w0UegfFKDnRwur4LmeZW4lqX8S46Sib
QgIIOhlGwR9ueG2q3OVN7y4AcPXasoH9UGhKaYH1KODJ04z4Ho7N1Aye/hffYf2/xp6suXEc
57/i2qeZqq9n4iNu56EfaEm2FetqUfKRF5XH8XRc04lTtlM7/e8/gNTBA3S2amc7BkCKpCgQ
AHH4R9AKjn99oHjO/3u87l967Lx/OV4Pe0ygoZA3u6tYBHmiR6PjOKU4Bvo+8wQHpM81lTJm
T6RGqtGoOfpARJC7w/Fo2PcJiAKfPjh3Bj+2JCXwZHdHHvMDIwUk1YuHPl4J3Y2fOLiF0j54
8hYhbX5TqBYlWwcuI2lNE04G95uNvpQVwCZjfas25MA6I8cqxywHIdBtL2zIQi/X41BpmpQH
ceh4VMIKxH72KPgzT5PUkXlGJfy0K+Sc6Pr9GV0OTMQlTatkaKp3W8ZrKs5ieB+0lqGSBQF9
HafSYOowOGfzT9eCpx7INsHm003IC/GaPiUraXu3SrJN0gy0gs/oVp9/wuvwyfX9xD5Ii3aS
EeVmcGtYpxtEphwE8ANTt+me3ggEUTjSnGkRaIYyIyzOMu1SS8BQqjKDFTt8qnVb6E9OdYdx
7E4onjpIGFMLVebhker0wSP1mhNxbZZDNdBRIDh86oUBEwc1/jVubAJocflyOT4feiWftsYB
nN/h8Iw53k9ngWnuWdjz7h2d1wgj1jpi9vEVvIn0Pesj3l/8Zqes+b13PQH1oXd9aai6M6vr
2nEdg3uKMu8rwptPpJh7e/+4Oi0yYZKVerIWBFSzGSaacl7QSCKUFYyrMoOCi4ufZczog0ES
xQwz+JlEYuzl5XD+iam9j5gS9u/dXs8TVrdPMa/lzXE8plv6Tk+ig5X0wzdaBStDVVTW07pN
0VqC6jBNWa4liWxgoOUvp7SVvyWJlp+SJMG6cKQsbGnwehYlc/oltmS8SNdsTapHHU2ZwJDI
+WzM+dhvR20nAKCcUN4WEge6ZMi07BMSLt0u0tIhrkmiqRffP3ylL+MlxYpvNhtGs+16ACAq
Z5hGqUJmcHNbYRgC7QYiSYT3nUPVkgQ4Hw7yh+Pitl5F0MvoC9E4HAnty9qni935WZjAwz/T
nmnWgxVWkkaLn/j/wkNetWkJBBxBxusyCHK2voFleN4w840bRICNXVabupvcc+yaUk5H2S9z
FgfkpYT3sjvv9sjSrbuRolDqXKyUs6RRoET+mEikdeEqZUOguDGtbRjQdWBMiuZrnk+Yj+xh
UmXFVrOyRsGceVsBdi4Ni9DrTF6u5jTXSKo5p+VEESqJGR2pYx64osxC2GkCwWoJINuAfDgf
dz+pw6weIcjvd1ar5PT2RSAusrk4jYmztu6jhCMesxjcWgnuecnGkfRfUtTb8bFgc+zwfyD9
lMyho9VokQe5dGXLicNK5q2nj3TYMzeSj+fDhzHN6kRyK3FPTb92D/7L7PcYDjzqBSCYnGFG
ayk8c2hCC9JDJsu4Ln0SfovNTi4yQd7kOs14b//zKO8J7XFjT14UotV1KaK26Yc3NJEvkxRS
7eeZ7jzTPr6uEHQ6X8wrQ5CKYXCn/T+22IVZifr3kwn0Lm15qvhYS/0o9ySuLEWKHLl7fhY5
q+EDEk+7/KEtQZh4RU6rwDgnl/fLmnZ8zdI1Jj1aOSp2CCwIHI4jT+J5CQc5bT1drGOHUIOW
nJjR81ijn7+f2rJa/PHzevz7420vcnrXMjDBpBYFJsrmoTck+49nPog7cebIHYrouBgPH746
0Ty+v6MXlE0393d31hGut95yz7EsiC7CisXD4f2mKrjHfIegEMzLyHnzlHs3RhD4IRMvjTpR
5+fd+8txb21+5mW939jH8/HU805tSuLf6aJYLPZ70fGv8+78q3c+fVyPb4fW6Dc7714Pvb8+
/v4bTm3fPLVnWqmH1osIhkyJpLNpk5O7O3kBlqSFkR0MgDNYj3Ce1MW1yJUBKqFjSoci+pMA
GlCjgykcXIVhEben99LIbMQehY7KVeBwggYk7/v9IUi2Lnw4jav5phjdO3IbAwnm+C0d3xjO
9abtCgiEZZ4vAsfXj4MM0XmOxKK9PcJyZFXk+c7tBtvncvop3D/ef+5+1QtlM1jp6WJJYRoY
U2qXMQhzkzsan6dr/m1w3+6UHMRK6fqj9NxNz0bDMYbFOPBCMGY5zfKoZnlauNIHRulckdzx
F97+lhvYiQmNWM2ZWmpHwXhRWQwGWhEhjncnti4BX5O1xItQc+GCn+grDBLTVrh9YkIAYvxA
hmFPneBLdFO70tlSJuYzh2MOh2PZ+rEhG6Ex3+yOeXm5oYcidUqrQYnR8I4W0yBaqjdLCPPg
cMq3JiyEX1uzb0+wU0ff3lZYt8w2sGLzNMlD7shXDiRBzKsZ7SQo0FHgpVRYh0A+YQpg6x3E
09ChTgj8LKdlUkRCf249XRBs3VNZg9id0iK8ePA2t74NjSDEGw831qE/IO6RTR0XKYgt1mGy
YNQ3KaecYF78Qtz7a+0iT4g9zn6jIElXpMsVItN5SO3pBl75j+6OGxr4kdEL2pI49g7i8zKe
RkHG/MEtqvnD6O4Wfg3HQnRzj8ZsHnrCAHODZDuLGHfwFYyYE1+K/iHKm5t0VhjgFHOt2Rtf
2L1v796kcGg3gINDK6ANQojNWIKCbJTe+LIyDC3aJvRBLgiAscAZ6cZHDO9vEyMPuE6TO33s
Ec1ZeGsat26BBD4LAt+Z6FBQ4FX6LSxsFjgDHKZLQVMmWeRQq8VmcKmgyEPQ3AbyvvtjF/cJ
j+n25iOKcEXfNQlkmvHAEfcj8Iu85IWMJnESlXhYVhmn9RKk2IRJ7B4E+tncnMLT1ofj8QY3
5cDXxMUtrSaK4zIiy0SWfFqlCy+sUPQFocasUov4WszTgaJCGdYQWXiaxdkwxsobAoBRrgII
z15+XbCMby/a/UKLny1TJ2kmnrjxgpC+P0DsnPkudxkMH6b1LWxYRlnoNP2Ua3pF45juMIYj
3mlsToI1nCM+/STmYQXTUIbrES8qB+1Xq9KFAJG5TwctvCLlWxpY32J++8/5ur/7j0oAyAK2
gd6qBhqtOnW08G5EriIWfd9t8xVg9KsipUWYFLPaz/OXBa+r9ZhgI4JChVdlGGDxHFpbEhPI
V1ZJ4NbIhiM1tiwa0xxgNAU5WrW1hXScNRKf9weT8c3BAsl9n7ZSqCT3NDNSSMaT+zrN9GeU
X0f0pUBHMhjdOSycNQkvlv2vBZvcJIpHk+KT2SPJkI7cVUnuH26T8Hg8+GRS0++jyd1tkjy7
9xwGo4ZkNbwb2Cb109sXzJWnbwajZa1eaaHiNWpWwF93fbtfVLn44Q2jC4hN6McMNFilMEun
T+IdP3on0pyp3PghzwzXzI5FOuIVRS0iad2mOR4ShCmwzKS0ZhIf9+fT5fT3tbf49X44f1n1
fnwcLlfy3qFgTpf6xbqpq05zaxZG05QWsMJUlhGjLRz54fV0PWAwh7nK+fvr5Qd5x4JK+zok
LgF56vV+46IMdS9963kvx/ffe5emLJgRD8Jef55+AJifrBc8PZ92z/vTK4U7/hFvKPj3j91P
aGK2UUbtVbogLbAbLPT5r6vRBl1SNtXKo6uWZejpu5rlDu+jYIPukK7jNXVYaELHNszWxAVK
/r23h1W2zSUsjytQcDAZXJXk3/pK/5lIbu6QE4Q1XXHJpI1IsW0tyRZbrQh5S9xEKiIBaYnz
4mqZJgxlmIGTCq8ksg2rBpMkxnsdWmrRqLA/mgoVZM/hJRJ7tKCUMzsLG3t7Pp+Oz+psGfoC
k9Zgn200j1RSpFis0R91j048JIeglRgRhEYheOhgCjwKY2ML6Oe7dWEt4p0WLPdFvOsv9wW3
tDNjSTG5F1TzOUduJMrJqR8JaPr0ZgTc0MB1mFGlylYCgN4UWF0c+zSegdR1iW7m0VJUQ8UD
r3Q63AuiIBHhEs4inkjjulJ8nPra2PC3kxijmqdG1HYehFgBm1d6CFELFqmyHd92TSLepbNM
j/KAaoNxT9QsrOc/frq+j5+tLRK45XDR/HbJMXNMCBH5SskON5+OGCkcl/GISusqol7uUFeR
CD4Xepdsbs52PuPmZ1FjsGjIQE7UgFTpwJsS4DZcRsnv3D5IUsnAo5jxZZTSA1LpyHFNC3tT
NrBP1rklE3u3C0+5TZyXCRbLADqh+NAsRFK711niQfkMHC+6e1wwE5E4M3pYSRjZr6zj0APR
CY3jeDbQX3+7biqnQ0FuxnUGJ2F16FhKWkhQLm6iybruRN2NAkur0njotGN33eaa8fYasznf
TEAoAWL7Kf0xk05mFNZ/tglbcC/kIlmqMt0sB3BNiN+XS2qWFC7mKrF1FY2uDZaPXNHKkMRR
TmGiL69QXhMri3TGR9qHKmEaaCbOLAXgoQNj9w3DjgN9xfisOmibtq2CfyhmQVCyaM22MAqs
VLvW8ut0xGHiB7TkoBBt4A2LOVlihLer89Urm9wK/JNoERj9p7/yhcxgiQwhTx/G4zvtrH9M
o1AttfIERCq+9GdywaS2mPI/Z6z4MynoJ8ywzIzyAmS9chWyMknwd5eOzQ+wWOu30fArhQ9T
b4FuycW3/xwvp8nk/uFLX00WopCWxYy2KySFxT2ktHY5fDyfRP1Wa1pdfLoKWNahcyoM/T3U
nSuAov5snAJ3VQPJBcpbhJGfB4ptdRnkifoow+7VJGzp7JgiX8vtM0HSuOQPkJ1nfuXlAVPL
DMl/jC8MnVkFb0MrYBAr40pFKnrr0GK+tdoNZmb0HQjGSINgjJwLjV5x1TTaw2+0lxsD6KCf
nZuB+1SZulF2q2b9chZrvEj8loeKVsKIfy8ZX6ikDUSeIlZFZR0tGRExgJbMxwvkrK79TXZU
U4j7M1rFoSjrqsm3G7g2XUvwpNmvW3D0NCKhKTmBzdPtUTxxR3aelmIkwtIxOh3zytymDeJp
4Pt0gfX23dRJ++Trk8lqhoqZa+PaN3GI9Y31j05CqinuN3EVU/XH07CQJ4saUJPG5keRGYDv
yWZkg8bWh1sDb5jy62fRVgFepGS9e+AbK+3hpfVkCZGh1rRtkRpXw91rr0uSRyXyWdrv1cD4
PdSiBAXE5BkqUktkDkrVWtfIJU3VJ5rnmL0imXGTHIWY2nncT8j8ezURnhRBhETaFLT6Zty3
Z+QTUzLwVA77ufA3z9BhX9lxgp0ZPys9ZT1v6kSqcaF55pm/q7la0aGG1QvarFmGgdNIWC3z
6b2W9kPSuzesyBhHs+pQ34H4+0YteIFeB2xZZWtRhMBNVWYecwSxCrzFHXX0jckI9P/wBB5P
h31q+4GsxczD2sWTEi2tnaiuLqQsTQxT0I0cV4EcpzdsMV8B80pjvt47MJP7Oydm4MS4e3ON
YDJ2Pmfcd2KcIxgPnZiRE+Mc9XjsxDw4MA9DV5sH54o+DF3zeRi5njP5aswHdAncHdXE0aA/
cD4fUMZSM+6FId1/X99kDXhAUw9psGPs9zR4TIO/0uAHx7gdQ+k7xtI3BrNMw0mVE7BSh2Fi
ajiv1fwUDdgLIr0cTwtPiqBUU720mDxlRUj2tc3DKKJ6m7OAhudBsLTBIYyKJT6BSEqtEpU6
N3JIRZkvQ60cJSBQN+wgfqSnIoqITENCQ1wezm+Hn72X3f4fmcFVQN/Px7frP+Ke//n1cPlB
XaUKG4ssDEtyYuk6HKVzkfmq5a6tDiy1H4Ji1LhWv76D3vrlenw99PYvh/0/FzGgvYSflTE1
aksiilmgwQc6y0CFAOVPOcdrfFzyul6kYnRCr2fR8lv/bjBSb1TyEKPFY5DyYofnTIIBv4if
phFNcsMqKotP8HZARhsuk0+ikirKR9BCvEEklyBNIsq9Rvg1osyaf1eNfC2wtTbI5fp292+f
oqqjYq0BSwHOvuY+vJ7Ov3r+4a+PHz+MXMGCNwabAl1WHTcmgiRLMY+VI4+PtE+LW1OR1kxR
+j3hvcVZ4qWrOsJQCGrS+oMj6kWn/T8f73KDLXZvP/SdDt+hB8tZpbTdVMNXKxaVsGo6si6f
DGBjuRCxDAKz1Lt4PA6qW7Heb5f345uIqPq/3uvH9fDvAf44XPd//PGHkjdwvYYNXgQbeEHR
rJApxttnin0BohXm+BL1mYlovmZfYoLFOt1YOV8F+TTlauSCjZFOAV5Jv2Q/ZhXL3Ens8jLB
tRCWelgM4SyhWIgw3a2sfqVVzRJwHcSKNA698UhdgAYl3D8w+9e40jGin0WwEUl2jd5F4bYm
qMZALgFbpBsDKljjzACaFZYFsCz1cAMBRAsqFuchVkngc5TPjcq9cgJakWK5ZsvYfCQXkR3Z
1hyfWvpzBlo4jriaBoln1KEV1G1iY2OxpKnQeKLIdmYtKxy4HrrmW2uKGTnVOyLYaPBxYZ46
jArLS/fFqkyG7WDTU+7KKw5Ka8aMfLJ1HPH+43y8/rLPGjFu9cahS6gHKNwxDqtb3Za6spa3
KIHfLErbCH5XPtY3CmSsgSv4Wl6dwqcWcOGoATvXc4UK37hmbZD0eYV8Aa/5gwRGipsJ95LI
Ve0xzRZsEd1AVTPoAEOuNEuY3CJIg3FtN1J+ywOrWwDmqZxKx2Iq7hq1SXNpu+Qmj9DT3EkY
HC6e+tVI6CbNTVD2nWY5IJCkSrUEmZC69ZQ4/3q/nkC6OR96p3Pv5fDzXc0wLolhmefARJWz
TQUPbHigVoZXgDbpNFp6YbZQM9+ZGLuRYDgU0CbN1eoIHYwkbEVBa+jOkTDX6JdZZlMv1XxF
TQ9oBCaGw5lF6i8sUOARwDpDp9VnDbcfVnJiBk2eTz/kQn4Vd9lW0/msP5jEZWQ1x/zqJNB+
PFoZZRFuEyP+sbdS7ICzslgEan6lGl4futI36uP6cni7HvcivXXwtscPAOOi/3u8vvTY5XLa
HwXK31131ofgqWUdmiUgYN6Cwf8Gd1kabfvDO8261n4P8xC9kWl7k07jMEopRIN72q+3WbE0
L/l4RMe8qjTwsDtKr5IkPPgeWqwEc2UzkH1XzRJPRbT/6+lZS/RfL8zUfj3ebGrDCntHegUn
nm23jfK1BcuoB2+IDuHQW+esLXW+2F1eXFPRSrc2XIgCbqiHrySl1AaOPw6Xq/2E3BsOPPVs
UhHu1wToon/nhzP7c9VltWZxul1qbAl/RMAIuhC2AOjScWjPM4992FQkWLUNduDB/ZgCDwc2
tagQRgCpLgB83x9Q4KENjG1YMc/7D3b7dSZ7lafp8f1FczZvP1GbcwIM1DCbhyXlNLS3Jcs9
+1WAELGehcQLbRDNbYH1JbE4iKLQPmIwoay7ES/sV49Qe7H9wJ7CzMjl3HxwC/ZEiAucRZwR
r7zhrHaDICB6CfJMK/fVvmB7NXkWqAmF27PDXqVinZLLXsO7BWwtSufD5aJVfG3XychN2LCw
p9SCTUb27sOrXQK20MIaarh5cSsV593b8+m1l3y8/nU4yzo4Rm3adl9i3v2Mkqf8fForziRG
sERz90sMJccJDLJ/CmE94THEWPsA3cJVIVkRbFD9dyIqkh+2WO4S71oKaj1aZC0Hmy9iQecJ
A5k9xuQSUj0VQXW2W9LhfMWgBZBQLiJP4+X4420n0v4KW6Vh/ZDXtlj4DLNK8FZJtG0+dtqR
ugupQ6i6BejnWK4oV+0yjTM96H6Jh3oVljbRHexUkihIHFjM7lgWoXpJ1jrqe2Hrpm2gDLCH
iVw82Bnqq/HU9A9IYR+R0FFRVnqroSavwk/CwFPDo9ALptuJfl4rGDqCqyZh+Zo5LuklBSy7
C+vs+CshI0ThtJYrtJ3pTQjazab+PjpXBWG4U1aBaAWMqk1R2i0SQqXLiw5HpxV0+o40lykB
tbgjsEWiZ4QqPXcX6E8jkhrYIw0ne0G2SZALMDWfzROCu/byd7VREzfXMBHwkdm0IRuPLCDL
YwpWLMp4aiEw5ajd79R7tGD6Tu4mVM2fQuWTUhBTQAxITPQUMxKxeXLQpw64Mv0iADE9wGho
ClYtdctpC5/GJHjGFTjjmFOZYZ57WMqcaaYiERMSKGvO55G0Nylj/q4mjo/QA8FmTo1lWNmY
eVm7onUsJHrCLJka70hzP6TjiXzfkfo2/y7y0VL3L1mI3mHtA1ORKQI0x0JN2TJLk0IJR+/c
QQFO+m4j/eTfiXKlJSEqs+UY2pQqK8Vro3QHkMZuhbP+P0nyIWSEtgAA

--ZGiS0Q5IWpPtfppv--

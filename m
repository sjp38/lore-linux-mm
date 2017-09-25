Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9DC6B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:06:48 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c195so4597554itb.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:06:48 -0700 (PDT)
Received: from smtp124.ord1c.emailsrvr.com (smtp124.ord1c.emailsrvr.com. [108.166.43.124])
        by mx.google.com with ESMTPS id w194si5571922iow.110.2017.09.25.08.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 08:06:46 -0700 (PDT)
Subject: Re: include/linux/kernel.h:860:32: error: dereferencing pointer to
 incomplete type 'struct clock_event_device'
References: <201709241605.EczNVSR7%fengguang.wu@intel.com>
From: Ian Abbott <abbotti@mev.co.uk>
Message-ID: <d1314ad7-cc8c-1705-5dd0-bd17eb81a9bb@mev.co.uk>
Date: Mon, 25 Sep 2017 16:06:44 +0100
MIME-Version: 1.0
In-Reply-To: <201709241605.EczNVSR7%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 24/09/17 09:26, kbuild test robot wrote:
> Hi Ian,
> 
> FYI, the error/warning still remains.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   cd4175b11685b11c40e31a03e05084cc212b0649
> commit: c7acec713d14c6ce8a20154f9dfda258d6bcad3b kernel.h: handle pointers to arrays better in container_of()
> date:   2 months ago
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          git checkout c7acec713d14c6ce8a20154f9dfda258d6bcad3b
>          # save the attached .config to linux build tree
>          make.cross ARCH=ia64
> 
> All errors (new ones prefixed by >>):
> 
>     In file included from drivers/clocksource/timer-of.c:25:0:
>     drivers/clocksource/timer-of.h:35:28: error: field 'clkevt' has incomplete type
>       struct clock_event_device clkevt;
>                                 ^~~~~~

That's the first compile error - 'struct clock_event_device' is 
incomplete because 'CONFIG_GENERIC_CLOCKEVENTS' is not defined.

>     In file included from include/linux/err.h:4:0,
>                      from include/linux/clk.h:15,
>                      from drivers/clocksource/timer-of.c:18:
>     drivers/clocksource/timer-of.h: In function 'to_timer_of':
>>> include/linux/kernel.h:860:32: error: dereferencing pointer to incomplete type 'struct clock_event_device'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>                                     ^~~~~~
>     include/linux/compiler.h:517:19: note: in definition of macro '__compiletime_assert'
>        bool __cond = !(condition);    \
>                        ^~~~~~~~~
>     include/linux/compiler.h:537:2: note: in expansion of macro '_compiletime_assert'
>       _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>       ^~~~~~~~~~~~~~~~~~~
>     include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
>      #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                          ^~~~~~~~~~~~~~~~~~
>     include/linux/kernel.h:860:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>       ^~~~~~~~~~~~~~~~
>     include/linux/kernel.h:860:20: note: in expansion of macro '__same_type'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>                         ^~~~~~~~~~~
>     drivers/clocksource/timer-of.h:44:9: note: in expansion of macro 'container_of'
>       return container_of(clkevt, struct timer_of, clkevt);
>              ^~~~~~~~~~~~
> --
>     In file included from drivers//clocksource/timer-of.c:25:0:
>     drivers//clocksource/timer-of.h:35:28: error: field 'clkevt' has incomplete type
>       struct clock_event_device clkevt;
>                                 ^~~~~~
>     In file included from include/linux/err.h:4:0,
>                      from include/linux/clk.h:15,
>                      from drivers//clocksource/timer-of.c:18:
>     drivers//clocksource/timer-of.h: In function 'to_timer_of':
>>> include/linux/kernel.h:860:32: error: dereferencing pointer to incomplete type 'struct clock_event_device'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>                                     ^~~~~~
>     include/linux/compiler.h:517:19: note: in definition of macro '__compiletime_assert'
>        bool __cond = !(condition);    \
>                        ^~~~~~~~~
>     include/linux/compiler.h:537:2: note: in expansion of macro '_compiletime_assert'
>       _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>       ^~~~~~~~~~~~~~~~~~~
>     include/linux/build_bug.h:46:37: note: in expansion of macro 'compiletime_assert'
>      #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                          ^~~~~~~~~~~~~~~~~~
>     include/linux/kernel.h:860:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>       ^~~~~~~~~~~~~~~~
>     include/linux/kernel.h:860:20: note: in expansion of macro '__same_type'
>       BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>                         ^~~~~~~~~~~
>     drivers//clocksource/timer-of.h:44:9: note: in expansion of macro 'container_of'
>       return container_of(clkevt, struct timer_of, clkevt);
>              ^~~~~~~~~~~~
> 
> vim +860 include/linux/kernel.h
> 
>     843	
>     844	
>     845	/*
>     846	 * swap - swap value of @a and @b
>     847	 */
>     848	#define swap(a, b) \
>     849		do { typeof(a) __tmp = (a); (a) = (b); (b) = __tmp; } while (0)
>     850	
>     851	/**
>     852	 * container_of - cast a member of a structure out to the containing structure
>     853	 * @ptr:	the pointer to the member.
>     854	 * @type:	the type of the container struct this is embedded in.
>     855	 * @member:	the name of the member within the struct.
>     856	 *
>     857	 */
>     858	#define container_of(ptr, type, member) ({				\
>     859		void *__mptr = (void *)(ptr);					\
>   > 860		BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) &&	\
>     861				 !__same_type(*(ptr), void),			\
>     862				 "pointer type mismatch in container_of()");	\
>     863		((type *)(__mptr - offsetof(type, member))); })
>     864	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

Cc'ing Daniel Lezcano and Thomas Gleixner, since this seems to be a 
problem with configurations selecting 'TIMER_OF' even though 
'GENERIC_CLOCKEVENTS' is not selected.

There was a recent-ish commit 599dc457c79b 
("clocksource/drivers/Kconfig: Fix CLKSRC_PISTACHIO dependencies") to 
address this problem for one particular clocksource driver, but some 
other clocksource drivers seem to share the same problem.  There are 
several clocksource config options in "drivers/clocksource/Kconfig" that 
select 'TIMER_OF' without depending on 'GENERIC_CLOCKEVENTS'.  Some of 
them are only manually selectable when 'COMPILE_TEST' is selected.  This 
particular failure seems to be at least partly due to 'ARMV7M_SYSTICK' 
getting selected.

-- 
-=( Ian Abbott @ MEV Ltd.    E-mail: <abbotti@mev.co.uk> )=-
-=(                          Web: http://www.mev.co.uk/  )=-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

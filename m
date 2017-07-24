Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 263606B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:31:53 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so578183qkl.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 03:31:53 -0700 (PDT)
Received: from smtp116.iad3a.emailsrvr.com (smtp116.iad3a.emailsrvr.com. [173.203.187.116])
        by mx.google.com with ESMTPS id r88si8836601qtd.448.2017.07.24.03.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 03:31:52 -0700 (PDT)
Subject: Re: include/linux/kernel.h:860:32: error: dereferencing pointer to
 incomplete type 'struct clock_event_device'
References: <201707231211.ieDvuzfs%fengguang.wu@intel.com>
From: Ian Abbott <abbotti@mev.co.uk>
Message-ID: <87c98bfa-8a6d-4bc6-65e5-7b65afa072da@mev.co.uk>
Date: Mon, 24 Jul 2017 11:31:49 +0100
MIME-Version: 1.0
In-Reply-To: <201707231211.ieDvuzfs%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Matt Redfearn <matt.redfearn@imgtec.com>

On 23/07/17 05:56, kbuild test robot wrote:
> Hi Ian,
> 
> FYI, the error/warning still remains.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   96080f697786e0a30006fcbcc5b53f350fcb3e9f
> commit: c7acec713d14c6ce8a20154f9dfda258d6bcad3b kernel.h: handle pointers to arrays better in container_of()
> date:   10 days ago
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>          wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
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

Matt Redfearn sent a fix 6 days ago.  It didn't get Cc'ed to LKML, but 
it did get Cc'd to the CLOCKSOURCE maintainers.  Does it need re-posting?

-- 
-=( Ian Abbott @ MEV Ltd.    E-mail: <abbotti@mev.co.uk> )=-
-=(                          Web: http://www.mev.co.uk/  )=-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

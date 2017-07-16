Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 634956B0502
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 10:23:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c18so63688136qkb.10
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 07:23:33 -0700 (PDT)
Received: from smtp108.iad3a.emailsrvr.com (smtp108.iad3a.emailsrvr.com. [173.203.187.108])
        by mx.google.com with ESMTPS id c11si1152515qtd.114.2017.07.16.07.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 07:23:32 -0700 (PDT)
Subject: Re: include/linux/kernel.h:860:32: error: dereferencing pointer to
 incomplete type 'struct clock_event_device'
From: Ian Abbott <abbotti@mev.co.uk>
References: <201707161158.V5vr9Ak9%fengguang.wu@intel.com>
 <b281909c-f4de-dadd-3d87-2ed2cc5dae1b@mev.co.uk>
 <f34577c1-4814-e13a-1cd9-8a621bccf98b@mev.co.uk>
Message-ID: <d5581fe0-2420-655b-3c3c-25c316f05576@mev.co.uk>
Date: Sun, 16 Jul 2017 15:23:22 +0100
MIME-Version: 1.0
In-Reply-To: <f34577c1-4814-e13a-1cd9-8a621bccf98b@mev.co.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-mips@linux-mips.org

On 16/07/17 15:14, Ian Abbott wrote:
> On 16/07/17 14:50, Ian Abbott wrote:
>> On 16/07/17 04:24, kbuild test robot wrote:
>>> tree: 
>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git 
>>> master
>>> head:   5771a8c08880cdca3bfb4a3fc6d309d6bba20877
>>> commit: c7acec713d14c6ce8a20154f9dfda258d6bcad3b kernel.h: handle 
>>> pointers to arrays better in container_of()
>>> date:   3 days ago
>>> config: ia64-allyesconfig (attached as .config)
>>> compiler: ia64-linux-gcc (GCC) 6.2.0
>>> reproduce:
>>>         wget 
>>> https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross 
>>> -O ~/bin/make.cross
>>>         chmod +x ~/bin/make.cross
>>>         git checkout c7acec713d14c6ce8a20154f9dfda258d6bcad3b
>>>         # save the attached .config to linux build tree
>>>         make.cross ARCH=ia64
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>    In file included from drivers/clocksource/timer-of.c:25:0:
>>>    drivers/clocksource/timer-of.h:35:28: error: field 'clkevt' has 
>>> incomplete type
>>>      struct clock_event_device clkevt;
>>>                                ^~~~~~
>>>    In file included from include/linux/err.h:4:0,
>>>                     from include/linux/clk.h:15,
>>>                     from drivers/clocksource/timer-of.c:18:
>>>    drivers/clocksource/timer-of.h: In function 'to_timer_of':
>>>>> include/linux/kernel.h:860:32: error: dereferencing pointer to 
>>>>> incomplete type 'struct clock_event_device'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>                                    ^~~~~~
>>>    include/linux/compiler.h:517:19: note: in definition of macro 
>>> '__compiletime_assert'
>>>       bool __cond = !(condition);    \
>>>                       ^~~~~~~~~
>>>    include/linux/compiler.h:537:2: note: in expansion of macro 
>>> '_compiletime_assert'
>>>      _compiletime_assert(condition, msg, __compiletime_assert_, 
>>> __LINE__)
>>>      ^~~~~~~~~~~~~~~~~~~
>>>    include/linux/build_bug.h:46:37: note: in expansion of macro 
>>> 'compiletime_assert'
>>>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>>>                                         ^~~~~~~~~~~~~~~~~~
>>>    include/linux/kernel.h:860:2: note: in expansion of macro 
>>> 'BUILD_BUG_ON_MSG'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>      ^~~~~~~~~~~~~~~~
>>>    include/linux/kernel.h:860:20: note: in expansion of macro 
>>> '__same_type'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>                        ^~~~~~~~~~~
>>>    drivers/clocksource/timer-of.h:44:9: note: in expansion of macro 
>>> 'container_of'
>>>      return container_of(clkevt, struct timer_of, clkevt);
>>>             ^~~~~~~~~~~~
>>> -- 
>>>    In file included from drivers//clocksource/timer-of.c:25:0:
>>>    drivers//clocksource/timer-of.h:35:28: error: field 'clkevt' has 
>>> incomplete type
>>>      struct clock_event_device clkevt;
>>>                                ^~~~~~
>>>    In file included from include/linux/err.h:4:0,
>>>                     from include/linux/clk.h:15,
>>>                     from drivers//clocksource/timer-of.c:18:
>>>    drivers//clocksource/timer-of.h: In function 'to_timer_of':
>>>>> include/linux/kernel.h:860:32: error: dereferencing pointer to 
>>>>> incomplete type 'struct clock_event_device'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>                                    ^~~~~~
>>>    include/linux/compiler.h:517:19: note: in definition of macro 
>>> '__compiletime_assert'
>>>       bool __cond = !(condition);    \
>>>                       ^~~~~~~~~
>>>    include/linux/compiler.h:537:2: note: in expansion of macro 
>>> '_compiletime_assert'
>>>      _compiletime_assert(condition, msg, __compiletime_assert_, 
>>> __LINE__)
>>>      ^~~~~~~~~~~~~~~~~~~
>>>    include/linux/build_bug.h:46:37: note: in expansion of macro 
>>> 'compiletime_assert'
>>>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>>>                                         ^~~~~~~~~~~~~~~~~~
>>>    include/linux/kernel.h:860:2: note: in expansion of macro 
>>> 'BUILD_BUG_ON_MSG'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>      ^~~~~~~~~~~~~~~~
>>>    include/linux/kernel.h:860:20: note: in expansion of macro 
>>> '__same_type'
>>>      BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) && \
>>>                        ^~~~~~~~~~~
>>>    drivers//clocksource/timer-of.h:44:9: note: in expansion of macro 
>>> 'container_of'
>>>      return container_of(clkevt, struct timer_of, clkevt);
>>>             ^~~~~~~~~~~~
>>>
>>> vim +860 include/linux/kernel.h
>>>
>>>    843
>>>    844
>>>    845    /*
>>>    846     * swap - swap value of @a and @b
>>>    847     */
>>>    848    #define swap(a, b) \
>>>    849        do { typeof(a) __tmp = (a); (a) = (b); (b) = __tmp; } 
>>> while (0)
>>>    850
>>>    851    /**
>>>    852     * container_of - cast a member of a structure out to the 
>>> containing structure
>>>    853     * @ptr:    the pointer to the member.
>>>    854     * @type:    the type of the container struct this is 
>>> embedded in.
>>>    855     * @member:    the name of the member within the struct.
>>>    856     *
>>>    857     */
>>>    858    #define container_of(ptr, type, member) ({                \
>>>    859        void *__mptr = (void *)(ptr);                    \
>>>  > 860        BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type 
>>> *)0)->member) &&    \
>>>    861                 !__same_type(*(ptr), void),            \
>>>    862                 "pointer type mismatch in container_of()");    \
>>>    863        ((type *)(__mptr - offsetof(type, member))); })
>>>    864
>>>
>>> ---
>>> 0-DAY kernel test infrastructure                Open Source 
>>> Technology Center
>>> https://lists.01.org/pipermail/kbuild-all                   Intel 
>>> Corporation
>>>
>>
>> struct clock_event_device is only completely defined when 
>> CONFIG_GENERIC_CLOCKEVENTS is defined, which it isn't.  But I'm 
>> confused as to why TIMER_OF getting selected by allyesconfig since it 
>> depends on GENERIC_CLOCKEVENTS.
>>
> 
> It seems to be due to CLKSRC_PISTACHIO being selected,  I guess that 
> should also depend on GENERIC_CLOCKEVENTS.
> 

Cc'ing linux-mips@linux-mips.org.

-- 
-=( Ian Abbott @ MEV Ltd.    E-mail: <abbotti@mev.co.uk> )=-
-=(                          Web: http://www.mev.co.uk/  )=-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

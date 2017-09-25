Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96F216B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:38:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so14143988pff.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:38:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e5sor2624386pfk.117.2017.09.25.09.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 09:38:00 -0700 (PDT)
Subject: Re: include/linux/kernel.h:860:32: error: dereferencing pointer to
 incomplete type 'struct clock_event_device'
References: <201709241605.EczNVSR7%fengguang.wu@intel.com>
 <176e63fe-59af-84f4-b0f5-d70b3db0c1e5@mev.co.uk>
From: Daniel Lezcano <daniel.lezcano@linaro.org>
Message-ID: <2a392cd7-22b3-f41d-b4e4-7b97bf2f3637@linaro.org>
Date: Mon, 25 Sep 2017 18:37:57 +0200
MIME-Version: 1.0
In-Reply-To: <176e63fe-59af-84f4-b0f5-d70b3db0c1e5@mev.co.uk>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Abbott <abbotti@mev.co.uk>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>

On 25/09/2017 17:15, Ian Abbott wrote:
> [Sorry for the repost.A  I forgot to Cc the people I said I was Cc'ing!]

Hi Ian,

[ ... ]


> On 24/09/17 09:26, kbuild test robot wrote:
>> Hi Ian,
>>
>> FYI, the error/warning still remains.
>>
>> tree:A A 
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:A A  cd4175b11685b11c40e31a03e05084cc212b0649
>> commit: c7acec713d14c6ce8a20154f9dfda258d6bcad3b kernel.h: handle
>> pointers to arrays better in container_of()
>> date:A A  2 months ago
>> config: ia64-allmodconfig (attached as .config)
>> compiler: ia64-linux-gcc (GCC) 6.2.0
>> reproduce:
>> A A A A A A A A  wget
>> https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross
>> -O ~/bin/make.cross
>> A A A A A A A A  chmod +x ~/bin/make.cross
>> A A A A A A A A  git checkout c7acec713d14c6ce8a20154f9dfda258d6bcad3b
>> A A A A A A A A  # save the attached .config to linux build tree
>> A A A A A A A A  make.cross ARCH=ia64
>>
>> All errors (new ones prefixed by >>):
>>
>> A A A  In file included from drivers/clocksource/timer-of.c:25:0:
>> A A A  drivers/clocksource/timer-of.h:35:28: error: field 'clkevt' has
>> incomplete type
>> A A A A A  struct clock_event_device clkevt;

[ ... ]

> 
> Cc'ing Daniel Lezcano and Thomas Gleixner, since this seems to be a
> problem with configurations selecting 'TIMER_OF' even though
> 'GENERIC_CLOCKEVENTS' is not selected.
> 
> There was a recent-ish commit 599dc457c79b
> ("clocksource/drivers/Kconfig: Fix CLKSRC_PISTACHIO dependencies") to
> address this problem for one particular clocksource driver, but some
> other clocksource drivers seem to share the same problem.A  There are
> several clocksource config options in "drivers/clocksource/Kconfig" that
> select 'TIMER_OF' without depending on 'GENERIC_CLOCKEVENTS'.A  Some of
> them are only manually selectable when 'COMPILE_TEST' is selected.A  This
> particular failure seems to be at least partly due to 'ARMV7M_SYSTICK'
> getting selected.

Thanks for Cc'ing. This issue is currently in the way to be fixed.

https://patchwork.kernel.org/patch/9939191/

  -- Daniel

-- 
 <http://www.linaro.org/> Linaro.org a?? Open source software for ARM SoCs

Follow Linaro:  <http://www.facebook.com/pages/Linaro> Facebook |
<http://twitter.com/#!/linaroorg> Twitter |
<http://www.linaro.org/linaro-blog/> Blog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

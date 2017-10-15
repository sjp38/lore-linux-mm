Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E07CD6B0033
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 22:21:50 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j140so9644781itj.10
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 19:21:50 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u7si3046918itd.45.2017.10.14.19.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Oct 2017 19:21:49 -0700 (PDT)
Subject: Re: [mmotm:master 120/209] warning:
 (FAULT_INJECTION_STACKTRACE_FILTER && ..) selects FRAME_POINTER which has
 unmet direct dependencies (DEBUG_KERNEL && ..) || ..)
References: <201710141255.eqxNqLrb%fengguang.wu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <0b40bf6c-7454-c8e6-045b-1a3cfbf6c4b3@infradead.org>
Date: Sat, 14 Oct 2017 19:21:34 -0700
MIME-Version: 1.0
In-Reply-To: <201710141255.eqxNqLrb%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 10/13/17 21:20, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   cc4a10c92b384ba2b80393c37639808df0ebbf56
> commit: 05f4b3e9e49122144fa1c5b1f3a3dc9b1c2c643a [120/209] kmemcheck: rip it out
> config: ia64-allyesconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 05f4b3e9e49122144fa1c5b1f3a3dc9b1c2c643a
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 
> All warnings (new ones prefixed by >>):
> 
> warning: (FAULT_INJECTION_STACKTRACE_FILTER && LATENCYTOP && LOCKDEP) selects FRAME_POINTER which has unmet direct dependencies (DEBUG_KERNEL && (CRIS || M68K || FRV || UML || SUPERH || BLACKFIN || MN10300 || METAG) || ARCH_WANT_FRAME_POINTERS)

So this one isn't new, right?

It also occurs in linux-next, 4.14-rc4, 4.14-rc3, 4.14-rc2, and 4.13.
That's all that I have checked so far.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

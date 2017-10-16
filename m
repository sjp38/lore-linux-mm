Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C050F6B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 23:58:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r25so5989478pgn.23
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 20:58:28 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 11si4030078plf.247.2017.10.15.20.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Oct 2017 20:58:27 -0700 (PDT)
Date: Mon, 16 Oct 2017 11:58:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 120/209] warning:
 (FAULT_INJECTION_STACKTRACE_FILTER && ..) selects FRAME_POINTER which has
 unmet direct dependencies (DEBUG_KERNEL && ..) || ..)
Message-ID: <20171016035824.s5afysu33xwgrpna@wfg-t540p.sh.intel.com>
References: <201710141255.eqxNqLrb%fengguang.wu@intel.com>
 <0b40bf6c-7454-c8e6-045b-1a3cfbf6c4b3@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <0b40bf6c-7454-c8e6-045b-1a3cfbf6c4b3@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Oct 14, 2017 at 07:21:34PM -0700, Randy Dunlap wrote:
>On 10/13/17 21:20, kbuild test robot wrote:
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   cc4a10c92b384ba2b80393c37639808df0ebbf56
>> commit: 05f4b3e9e49122144fa1c5b1f3a3dc9b1c2c643a [120/209] kmemcheck: rip it out
>> config: ia64-allyesconfig (attached as .config)
>> compiler: ia64-linux-gcc (GCC) 6.2.0
>> reproduce:
>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout 05f4b3e9e49122144fa1c5b1f3a3dc9b1c2c643a
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=ia64
>>
>> All warnings (new ones prefixed by >>):
>>
>> warning: (FAULT_INJECTION_STACKTRACE_FILTER && LATENCYTOP && LOCKDEP) selects FRAME_POINTER which has unmet direct dependencies (DEBUG_KERNEL && (CRIS || M68K || FRV || UML || SUPERH || BLACKFIN || MN10300 || METAG) || ARCH_WANT_FRAME_POINTERS)
>
>So this one isn't new, right?
>
>It also occurs in linux-next, 4.14-rc4, 4.14-rc3, 4.14-rc2, and 4.13.
>That's all that I have checked so far.

Yeah I can find that warning in reports back to 2014. So it's at least
3 years old.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

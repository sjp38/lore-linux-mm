Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63A366B75E5
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 20:36:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q21-v6so4844945pff.21
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 17:36:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m10-v6si3721351pgc.105.2018.09.05.17.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 17:36:38 -0700 (PDT)
Subject: Re: [LKP] 3f906ba236 [ 71.192813] WARNING: possible circular locking
 dependency detected
References: <20180905090553.GA6655@shao2-debian>
 <alpine.DEB.2.21.1809051459130.1416@nanos.tec.linutronix.de>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <7f0deb2e-f946-75fb-8ca9-5308fd5e5a9c@intel.com>
Date: Thu, 6 Sep 2018 08:37:00 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809051459130.1416@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>



On 09/05/2018 09:02 PM, Thomas Gleixner wrote:
> On Wed, 5 Sep 2018, kernel test robot wrote:
>
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>
>> commit 3f906ba23689a3f824424c50f3ae937c2c70f676
>> Author:     Thomas Gleixner <tglx@linutronix.de>
>> AuthorDate: Mon Jul 10 15:50:09 2017 -0700
>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>> CommitDate: Mon Jul 10 16:32:33 2017 -0700
> So it identified a more than one year old commit. Great.
>
>> vm86 returned ENOSYS, marking as inactive. 20044 iterations. [F:14867 S:5032 HI:3700] [ 57.651003] synth uevent: /module/pcmcia_core: unknown uevent action string [ 71.189062] [ 71.191953] ====================================================== [ 71.192813] WARNING: possible circular locking dependency detected [ 71.193664] 4.12.0-10480-g3f906ba #1 Not tainted [ 71.194355] ------------------------------------------------------ [ 71.195211] trinity-c0/1666 is trying to acquire lock: [ 71.195958] (mem_hotplug_lock.rw_sem){.+.+.+}, at: show_slab_objects+0x14b/0x440 [ 71.197284] [ 71.197284] but task is already holding lock:
> along with completely unparseable information. What am I supposed to do
> with this mail?
Hi,

Attached please find the dmesg/reproduce files in previous mail.
please ignore the report if it's a false positive.

Best Regards,
Rong Chen

>
> Thanks,
>
> 	tglx
> _______________________________________________
> LKP mailing list
> LKP@lists.01.org
> https://lists.01.org/mailman/listinfo/lkp

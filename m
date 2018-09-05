Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1B5C6B733D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:02:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id q18-v6so6658682wrr.12
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:02:46 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n16-v6si1685690wrp.217.2018.09.05.06.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 06:02:45 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:02:40 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [LKP] 3f906ba236 [ 71.192813] WARNING: possible circular locking
 dependency detected
In-Reply-To: <20180905090553.GA6655@shao2-debian>
Message-ID: <alpine.DEB.2.21.1809051459130.1416@nanos.tec.linutronix.de>
References: <20180905090553.GA6655@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, 5 Sep 2018, kernel test robot wrote:

> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> 
> commit 3f906ba23689a3f824424c50f3ae937c2c70f676
> Author:     Thomas Gleixner <tglx@linutronix.de>
> AuthorDate: Mon Jul 10 15:50:09 2017 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Mon Jul 10 16:32:33 2017 -0700

So it identified a more than one year old commit. Great.

> vm86 returned ENOSYS, marking as inactive. 20044 iterations. [F:14867 S:5032 HI:3700] [ 57.651003] synth uevent: /module/pcmcia_core: unknown uevent action string [ 71.189062] [ 71.191953] ====================================================== [ 71.192813] WARNING: possible circular locking dependency detected [ 71.193664] 4.12.0-10480-g3f906ba #1 Not tainted [ 71.194355] ------------------------------------------------------ [ 71.195211] trinity-c0/1666 is trying to acquire lock: [ 71.195958] (mem_hotplug_lock.rw_sem){.+.+.+}, at: show_slab_objects+0x14b/0x440 [ 71.197284] [ 71.197284] but task is already holding lock:

along with completely unparseable information. What am I supposed to do
with this mail?

Thanks,

	tglx

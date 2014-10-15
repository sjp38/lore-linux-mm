Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3609D6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 14:36:29 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1700972pdi.19
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 11:36:28 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id xi4si14035705pab.67.2014.10.15.11.36.28
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 11:36:28 -0700 (PDT)
Date: Wed, 15 Oct 2014 14:36:24 -0400 (EDT)
Message-Id: <20141015.143624.941838991598108211.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee>
	<20141014.173246.921084057467310731.davem@davemloft.net>
	<alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Wed, 15 Oct 2014 11:04:49 +0300 (EEST)

>> > My only other current sparc64 problems that I am seeing - V210/V440 die 
>> > during bootup if compiled with gcc 4.9 and V480 dies with FATAL 
>> > exceptions during bootups since previous kernel release. Maybe also 
>> > exit_mmap warning - I do not know if they have been fixed, I see them 
>> > rarely.
>> 
>> The gcc-4.9 case is interesting, are you saying that a gcc-4.9 compiled
>> kernel works fine on other systems?
> 
> Yes, all USII based systems work fine with Debian gcc-4.9, as does 
> T2000. Of USIII* systems, V210 and V440 exhibit the boot hang with 
> gcc-4.9 and V480 crashes wit FATAL exception during boot that is 
> probably earlier than the gcc boot hang so I do not know about V480 and 
> gcc-4.9. V240 not tested because of fan failures, V245 is in the queue 
> for setup but not tested so far.

Ok, on the V210/V440 can you boot with "-p" on the kernel boot command
line and post the log?  Let's start by seeing how far it gets, maybe
we can figure out roughly where it dies.

A boot hang should be relatively easy to diagnose and pinpoint.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

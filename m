Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD6B76B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 11:55:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f6so20600662qtd.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 08:55:27 -0700 (PDT)
Received: from cmta20.telus.net (cmta20.telus.net. [209.171.16.93])
        by mx.google.com with ESMTP id t124si10338233qkc.182.2016.10.07.08.55.26
        for <linux-mm@kvack.org>;
        Fri, 07 Oct 2016 08:55:27 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <bug-172981-27@https.bugzilla.kernel.org/> <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org> <20160928020347.GA21129@cmpxchg.org> <20160928080953.GA20312@esperanza> <20160929020050.GD29250@js1304-P5Q-DELUXE> <20160929134550.GB20312@esperanza> <20160930081940.GA3606@js1304-P5Q-DELUXE> <002601d21f8f$1fe2fe40$5fa8fac0$@net> s2GybGFijfdZcs2H3bZXPV 
In-Reply-To: 
Subject: RE: [Bug 172981] New: [bisected] SLAB: extreme load averages and over 2000 kworker threads
Date: Fri, 7 Oct 2016 08:55:23 -0700
Message-ID: <004d01d220b3$38a1ac40$a9e504c0$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>
Cc: 'Vladimir Davydov' <vdavydov.dev@gmail.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, 'Doug Smythies' <dsmythies@telus.net>

On 2016.10.06 09:02 Doug Smythies wrote:
> On 2016.10.05 23:35 Joonsoo Kim wrote:
>> On Wed, Oct 05, 2016 at 10:04:27PM -0700, Doug Smythies wrote:
>>> On 2016.09.30 12:59 Vladimir Davydov wrote:
>>> 
>>>> Yeah, you're right. We'd better do something about this
>>>> synchronize_sched(). I think moving it out of the slab_mutex and calling
>>>> it once for all caches in memcg_deactivate_kmem_caches() would resolve
>>>> the issue. I'll post the patches tomorrow.
>>> 
>>> Would someone please be kind enough to send me the patch set?
>>> 
>>> I didn't get them, and would like to test them.
>>> I have searched and searched and did manage to find:
>>> "[PATCH 2/2] slub: move synchronize_sched out of slab_mutex on shrink"
>>> And a thread about a patch 1 of 2:
>>> "Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating per-memcg caches"
>>> Where I see me as "reported by", but I guess "reported by" people don't get the e-mails.
>>> I haven't found PATCH 0/2, nor do I know if what I did find is current.
>>
>> I think that what you find is correct one. It has no cover-letter so
>> there is no [PATCH 0/2]. Anyway, to clarify, I add links to these
>> patches.
>>
>> https://patchwork.kernel.org/patch/9361853
>> https://patchwork.kernel.org/patch/9359271
>>
>> It would be very helpful if you test these patches.
>
> Yes, as best as I am able to test, the 2 patch set
> solves both this SLAB and the other SLUB bug reports.

I tested the patch from the other thread on top of these two,
And things continued to work fine. The additional patch
does seems a little faster under some of my hammering conditions.

Reference:
https://marc.info/?l=linux-kernel&m=147573486705407&w=2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

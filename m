Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D4C726B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:53:49 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id u188so119135136wmu.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:53:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lz8si3477317wjb.121.2016.01.26.10.53.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 10:53:48 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122163801.GA16668@cmpxchg.org>
 <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
 <56A6B1A2.40903@redhat.com> <20160126073846.GC28254@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A7C0B9.7040701@suse.cz>
Date: Tue, 26 Jan 2016 19:53:45 +0100
MIME-Version: 1.0
In-Reply-To: <20160126073846.GC28254@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On 26.1.2016 8:38, Joonsoo Kim wrote:
> On Mon, Jan 25, 2016 at 03:37:06PM -0800, Laura Abbott wrote:
>>
>> Is that series going to conflict with the work done for ZONE_DEVICE or run
>> into similar problems?
>> 033fbae988fcb67e5077203512181890848b8e90 (mm: ZONE_DEVICE for "device memory")
>> has commit text about running out of ZONE_SHIFT bits and needing to get
>> rid of ZONE_DMA instead so it seems like ZONE_CMA would run into the same
>> problem.
> 
> Hmm... I'm not sure. I need a investigation. What I did before is
> enlarging section size. Then, number of section is reduced and we need
> less section bit in struct page's flag. This worked for my sparsemem
> configuration but I'm not sure other conguration. Perhaps, in other
> congifuration, we can limit node bits and max number of node.

This seems to be a solution proposed for the ZONE_DMA and ZONE_DEVICE
coexistence https://lkml.org/lkml/2016/1/25/1233
It wouldn't help with ZONE_CMA, so I guess it's time to look for a more robust one.

> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

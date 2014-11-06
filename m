Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 743536B0099
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 06:53:25 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id n3so1180623wiv.2
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 03:53:24 -0800 (PST)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id j16si9496797wic.43.2014.11.06.03.53.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 03:53:24 -0800 (PST)
Date: Thu, 6 Nov 2014 12:53:22 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: isolate_freepages_block(): very high intermittent overhead
Message-ID: <20141106115322.GA17467@x4>
References: <20141027204003.GB348@x4>
 <544EC0C5.7050808@suse.cz>
 <20141028085916.GA337@x4>
 <545B5E90.6070902@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545B5E90.6070902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On 2014.11.06 at 12:42 +0100, Vlastimil Babka wrote:
> On 10/28/2014 09:59 AM, Markus Trippelsdorf wrote:
> > On 2014.10.27 at 23:01 +0100, Vlastimil Babka wrote:
> >> On 10/27/2014 09:40 PM, Markus Trippelsdorf wrote:
> >> > On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
> >> > high (>20%) in perf top during the configuration phase of software
> >> > builds. It increases build time considerably.
> >> > 
> >> > Unfortunately the issue is not 100% reproducible, because it appears
> >> > only intermittently. And the symptoms vanish after a few minutes.
> >> 
> >> Does it happen for long enough so you can capture it by perf record -g ?
> > 
> > It only happens when I use the "Lockless Allocator":
> > http://locklessinc.com/downloads/lockless_allocator_src.tgz
> > 
> > I use: LD_PRELOAD=/usr/lib/libllalloc.so.1.3 when building software,
> > because it gives me a ~8% speed boost over glibc's malloc.
> 
> I tried the allocator while updating my gentoo desktop with 3.18-rc3 and adding
> some extra memory pressure, but didn't observe anything like this. It could be
> system specific. If you do't have the time to debug, can you at least send me
> output of "cat /proc/zoneinfo"?

I will try to debug this further this weekend.
BTW there is an interesting thread on LKML that might be related to this
issue: https://lkml.org/lkml/2014/11/4/904

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

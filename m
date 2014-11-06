Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 348F66B0096
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 06:42:11 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so1173633wib.17
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 03:42:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si9468972wij.23.2014.11.06.03.42.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 03:42:09 -0800 (PST)
Message-ID: <545B5E90.6070902@suse.cz>
Date: Thu, 06 Nov 2014 12:42:08 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block(): very high intermittent overhead
References: <20141027204003.GB348@x4> <544EC0C5.7050808@suse.cz> <20141028085916.GA337@x4>
In-Reply-To: <20141028085916.GA337@x4>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-mm@kvack.org

On 10/28/2014 09:59 AM, Markus Trippelsdorf wrote:
> On 2014.10.27 at 23:01 +0100, Vlastimil Babka wrote:
>> On 10/27/2014 09:40 PM, Markus Trippelsdorf wrote:
>> > On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
>> > high (>20%) in perf top during the configuration phase of software
>> > builds. It increases build time considerably.
>> > 
>> > Unfortunately the issue is not 100% reproducible, because it appears
>> > only intermittently. And the symptoms vanish after a few minutes.
>> 
>> Does it happen for long enough so you can capture it by perf record -g ?
> 
> It only happens when I use the "Lockless Allocator":
> http://locklessinc.com/downloads/lockless_allocator_src.tgz
> 
> I use: LD_PRELOAD=/usr/lib/libllalloc.so.1.3 when building software,
> because it gives me a ~8% speed boost over glibc's malloc.

I tried the allocator while updating my gentoo desktop with 3.18-rc3 and adding
some extra memory pressure, but didn't observe anything like this. It could be
system specific. If you do't have the time to debug, can you at least send me
output of "cat /proc/zoneinfo"?

Thanks,
Vlastimil

> Unfortunately, I don't have time to debug this further and have disabled 
> "Transparent Hugepage Support" for now.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

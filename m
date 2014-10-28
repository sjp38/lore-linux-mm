Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id F2BC6900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 04:59:19 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id w7so177587lbi.24
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 01:59:19 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id ra5si1295010lbb.137.2014.10.28.01.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 01:59:18 -0700 (PDT)
Date: Tue, 28 Oct 2014 09:59:16 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: isolate_freepages_block(): very high intermittent overhead
Message-ID: <20141028085916.GA337@x4>
References: <20141027204003.GB348@x4>
 <544EC0C5.7050808@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <544EC0C5.7050808@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On 2014.10.27 at 23:01 +0100, Vlastimil Babka wrote:
> On 10/27/2014 09:40 PM, Markus Trippelsdorf wrote:
> > On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
> > high (>20%) in perf top during the configuration phase of software
> > builds. It increases build time considerably.
> > 
> > Unfortunately the issue is not 100% reproducible, because it appears
> > only intermittently. And the symptoms vanish after a few minutes.
> 
> Does it happen for long enough so you can capture it by perf record -g ?

It only happens when I use the "Lockless Allocator":
http://locklessinc.com/downloads/lockless_allocator_src.tgz

I use: LD_PRELOAD=/usr/lib/libllalloc.so.1.3 when building software,
because it gives me a ~8% speed boost over glibc's malloc.

Unfortunately, I don't have time to debug this further and have disabled 
"Transparent Hugepage Support" for now.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

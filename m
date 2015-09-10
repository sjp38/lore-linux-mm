Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB096B0258
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 13:02:59 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so35997621wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:02:58 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id p10si12684428wik.84.2015.09.10.10.02.57
        for <linux-mm@kvack.org>;
        Thu, 10 Sep 2015 10:02:57 -0700 (PDT)
Date: Thu, 10 Sep 2015 19:02:53 +0200
From: Andres Freund <andres@anarazel.de>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
Message-ID: <20150910170253.GA6197@alap3.anarazel.de>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150824201952.5931089.66204.70511@amd.com>
 <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150910164506.GK10639@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150910164506.GK10639@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: James Hartshorn <jhartshorn@connexity.com>, "Bridgman, John" <John.Bridgman@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2015-09-10 18:45:06 +0200, Andrea Arcangeli wrote:
> On Mon, Aug 24, 2015 at 08:46:11PM +0000, James Hartshorn wrote:
> > Some more links to discussion
> > about THP: Postgresql https://lwn.net/Articles/591723/ Postgresql
> > http://www.postgresql.org/message-id/20120821131254.1415a545@jekyl.davidgould.org
> 
> "and my interpretation was that it was trying to create hugepages from
> scattered fragments"
> 
> This is a very old email, but I'm just taking it as an example because
> this has to be a compaction issue. If you run into very visible hangs
> that goes away by disabling THP, it can't be THP to blame. THP can
> increase the latency jitter during page faults (real time sensitive
> application could notice a 2MB clear_page vs a 4KB clear_page), but
> not in a way that hangs a system and becomes visible to the user.
> 
> It's just very early compaction code was too aggressive and it got
> fixed in the meanwhile.

There's still some slowdown (as of 4.0) in extreme postgres workloads
with THP and/or compaction enabled, but I've indeed not been able to
reproduce bad stalls or large (10%+) slowdowns with recent kernels.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

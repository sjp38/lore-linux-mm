Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF2266B0038
	for <linux-mm@kvack.org>; Fri,  2 Jan 2015 08:35:10 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so27768041wib.4
        for <linux-mm@kvack.org>; Fri, 02 Jan 2015 05:35:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si58990866wjr.16.2015.01.02.05.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Jan 2015 05:35:09 -0800 (PST)
Date: Fri, 2 Jan 2015 13:35:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] mmap_sem and mm performance testing
Message-ID: <20150102133506.GB2395@suse.de>
References: <1419292284.8812.5.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1419292284.8812.5.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Mon, Dec 22, 2014 at 03:51:24PM -0800, Davidlohr Bueso wrote:
> Hello,
> 
> I would like to attend LSF/MM 2015. While I am very much interested in
> general mm performance topics, I would particularly like to discuss:
> 
> (1) Where we are at with the mmap_sem issues and progress. This topic
> constantly comes up each year [1,2,3] without much changing. While the
> issues are very clear (both long hold times, specially in fs paths and
> coarse lock granularity) it would be good to detail exactly *where*
> these problems are and what are some of the show stoppers. In addition,
> present overall progress and benchmark numbers on fine graining via
> range locking (I am currently working on this as a follow on to recent
> i_mmap locking patches) and experimental work,
> such as speculative page fault patches[4]. If nothing else, this session
> can/should produce a list of tangible todo items.
> 

There have been changes on mmap_sem hold times -- mmap_sem dropped by
khugepaged during allocation being a very obvious one but there are
others. The scope of what mmap_sem protects is similar but the stalling
behaviour has changed since this was last discussed. It's worth
revisiting where things stand and at the very least verify what cases
are currently causing problems.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

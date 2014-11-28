Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAD06B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 04:54:42 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so18031522wiv.5
        for <linux-mm@kvack.org>; Fri, 28 Nov 2014 01:54:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9si20613251wie.14.2014.11.28.01.54.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Nov 2014 01:54:41 -0800 (PST)
Date: Fri, 28 Nov 2014 10:54:31 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Improving CMA
Message-ID: <20141128095431.GB25991@quack.suse.cz>
References: <5473E146.7000503@codeaurora.org>
 <20141127061204.GA6850@js1304-P5Q-DELUXE>
 <20141128071327.GB11802@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141128071327.GB11802@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, minchan@kernel.org, SeongJae Park <sj38.park@gmail.com>, linux-mm@kvack.org, mgorman@suse.de, gioh.kim@lge.com, lsf-pc@lists.linux-foundation.org

On Fri 28-11-14 16:13:27, Joonsoo Kim wrote:
> On Thu, Nov 27, 2014 at 03:12:04PM +0900, Joonsoo Kim wrote:
> > On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
> > > There have been a number of patch series posted designed to improve various
> > > aspects of CMA. A sampling:
> > > 
> > > https://lkml.org/lkml/2014/10/15/623
> > > http://marc.info/?l=linux-mm&m=141571797202006&w=2
> > > https://lkml.org/lkml/2014/6/26/549
> > > 
> > > As far as I can tell, these are all trying to fix real problems with CMA but
> > > none of them have moved forward very much from what I can tell. The goal of
> > > this session would be to come out with an agreement on what are the biggest
> > > problems with CMA and the best ways to solve them.
> > 
> > I also tried to solve problem from CMA, that is, reserved memory
> > utilization.
> > 
> > https://lkml.org/lkml/2014/5/28/64
> > 
> > While playing that patchset, I found serious problem about free page
> > counting, so I stopped to develop it for a while and tried to fix it.
> > Now, it is fixed by me and I can continue my patchset.
> > 
> > https://lkml.org/lkml/2014/10/31/69
> > 
> > I heard that Minchan suggests new CMA zone like movable zone, and, I
> > think that it would be the way to go. But, it would be a long-term goal
> > and I'd like to solve utilization problem with my patchset for now.
> > It is the biggest issue and it already forces someone to develop
> > out of tree solution. It's not good that out of tree solution is used
> > more and more in the product so I'd like to fix it quickly at first
> > stage.
> > 
> > I think that CMA have big potential. If we fix problems of CMA
> > completely, it can be used for many places. One such case in my mind
> > is hugetlb or THP. Until now, hugetlb uses reserved approach, that is
> > very inefficient. System administrator carefully set the number of
> > reserved hugepage according to whole system workload. And application
> > can't use it freely, because it is very limited and managed resource.
> > If we use CMA for hugetlb, we can easily allocate hugepage and
> > application can use hugepages more freely.
> > 
> > Anyway, I'd like to attend LSF/MM and discuss this topic.
> 
> I change the subject according to LSF/MM attend request format.
> What I can do and why I'd like to attend is explained above.
> Sorry for noise.
  Guys (both you and Gioh), is it such a big problem to write *new* email
(not just reply to an existing thread), use proper subject (you did this)
and write there: "I'm interested in CMA discussion, I also do X & Y". The
call for proposals specifically says "Please summarise what expertise you
will bring to the meeting". That helps us to select people when we have
more requests than space available.

I know it sounds like stupid ranting but it really makes it easier for
program committee to select people and pick up all the topic requests and
it will take you like 5 minutes max.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

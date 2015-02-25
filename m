Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id B86AB6B006E
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 11:12:05 -0500 (EST)
Received: by labgf13 with SMTP id gf13so4978307lab.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 08:12:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si73927279wjz.86.2015.02.25.08.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 08:12:04 -0800 (PST)
Date: Wed, 25 Feb 2015 17:11:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC v2 0/5] introduce gcma
Message-ID: <20150225161158.GI26680@dhcp22.suse.cz>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
 <20150224144804.GE15626@dhcp22.suse.cz>
 <alpine.DEB.2.10.1502251403390.23105@hxeon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502251403390.23105@hxeon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 25-02-15 14:31:08, SeongJae Park wrote:
> Hello Michal,
> 
> Thanks for your comment :)
> 
> On Tue, 24 Feb 2015, Michal Hocko wrote:
> 
> >On Tue 24-02-15 04:54:18, SeongJae Park wrote:
> >[...]
> >> include/linux/cma.h  |    4 +
> >> include/linux/gcma.h |   64 +++
> >> mm/Kconfig           |   24 +
> >> mm/Makefile          |    1 +
> >> mm/cma.c             |  113 ++++-
> >> mm/gcma.c            | 1321 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >> 6 files changed, 1508 insertions(+), 19 deletions(-)
> >> create mode 100644 include/linux/gcma.h
> >> create mode 100644 mm/gcma.c
> >
> >Wow this is huge! And I do not see reason for it to be so big. Why
> >cannot you simply define (per-cma area) 2-class users policy? Either via
> >kernel command line or export areas to userspace and allow to set policy
> >there.
> 
> For implementation of the idea, we should develop not only policy selection,
> but also backend for discardable memory. Most part of this patch were made
> for the backend.

What is the backend and why is it needed? I thought the discardable will
go back to the CMA pool. I mean the cover email explained why the
current CMA allocation policy might lead to lower success rate or
stalls. So I would expect a new policy would be a relatively small
change in the CMA allocation path to serve 2-class users as per policy.
It is not clear to my why we need to pull a whole gcma layer in. I might
be missing something obvious because I haven't looked at the patches yet
but this should better be explained in the cover letter.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

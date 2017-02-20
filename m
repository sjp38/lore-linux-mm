Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFF96B0389
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 11:12:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so10844536wmg.4
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:12:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 80si24482628wrc.33.2017.02.20.08.12.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 08:12:01 -0800 (PST)
Date: Mon, 20 Feb 2017 17:11:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm,hugetlb: compute page_size_log properly
Message-ID: <20170220161157.GO2431@dhcp22.suse.cz>
References: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
 <1486673582-6979-5-git-send-email-dave@stgolabs.net>
 <20170210102044.GA10054@dhcp22.suse.cz>
 <20170210165111.GB2392@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210165111.GB2392@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

Sorry for a late reply, I wasn't online last week

On Fri 10-02-17 08:51:11, Davidlohr Bueso wrote:
> On Fri, 10 Feb 2017, Michal Hocko wrote:
> 
> > On Thu 09-02-17 12:53:02, Davidlohr Bueso wrote:
> > > The SHM_HUGE_* stuff  was introduced in:
> > > 
> > >    42d7395feb5 (mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB)
> > > 
> > > It unnecessarily adds another layer, specific to sysv shm, without
> > > anything special about it: the macros are identical to the MAP_HUGE_*
> > > stuff, which in turn does correctly describe the hugepage subsystem.
> > > 
> > > One example of the problems with extra layers what this patch fixes:
> > > mmap_pgoff() should never be using SHM_HUGE_* logic. It is obviously
> > > harmless but it would still be grand to get rid of it -- although
> > > now in the manpages I don't see that happening.
> > 
> > Can we just drop SHM_HUGE_MASK altogether? It is not exported in uapi
> > headers AFAICS.
> 
> Yeah that was my original idea, however I noticed that shmget.2 mentions
> kernel internals as part of SHM_HUGE_{2MB,1GB}, ie: SHM_HUGE_SHIFT. So
> dropping _MASK doesn't make sense if we are going to keep _SHIFT.

I am not sure I understand.
$ git grep SHM_HUGE_ include/uapi/
$

So there doesn't seem to be any user visible constant. The man page
mentiones is but I do not really see how is the userspace supposed to
use it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

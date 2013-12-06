Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 70C196B008A
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 13:32:16 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so461250eek.38
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 10:32:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si15707216eeg.198.2013.12.06.10.32.15
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 10:32:15 -0800 (PST)
Date: Fri, 6 Dec 2013 18:32:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131206183207.GW11295@suse.de>
References: <1386060721-3794-15-git-send-email-mgorman@suse.de>
 <529E641A.7040804@redhat.com>
 <20131203234637.GS11295@suse.de>
 <529F3D51.1090203@redhat.com>
 <20131204160741.GC11295@suse.de>
 <20131205104015.716ed0fe@annuminas.surriel.com>
 <20131205195446.GI11295@suse.de>
 <52A0DC7F.7050403@redhat.com>
 <20131206092400.GJ11295@suse.de>
 <20131206173843.GD3080@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131206173843.GD3080@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: t@sgi.com, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On Fri, Dec 06, 2013 at 11:38:43AM -0600, Alex Thorlton wrote:
> On Fri, Dec 06, 2013 at 09:24:00AM +0000, Mel Gorman wrote:
> > Good. So far I have not been seeing any problems with it at least.
> 
> I went through and tested all the different iterations of this patchset
> last night, and have hit a few problems, but I *think* this has solved
> the segfault problem.  I'm now hitting some rcu_sched stalls when
> running my tests.
> 

Well that's news for the start of the weekend.

> Initially things were getting hung up on a lock in change_huge_pmd, so
> I applied Kirill's patches to split up the PTL, which did manage to ease
> the contention on that lock, but, now it appears that I'm hitting stalls
> somewhere else.
> 

To check this, the next version of the series will be based on 3.13-rc2 which
will include Kirill's patches. If the segfault is cleared up then at least
that much will be in flight and in the process of being backported to 3.12.
NUMA balancing in 3.12 is quite work intensive but the patches 3.13-rc2
should substantially reduce that overhead. It'd be best to check them
all in combination and seeing what falls out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

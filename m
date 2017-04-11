Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACB376B03D0
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 17:44:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i5so5133168pfc.15
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:44:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p9si18053246pfe.205.2017.04.11.14.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 14:44:04 -0700 (PDT)
Date: Tue, 11 Apr 2017 14:44:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-Id: <20170411144402.1a2c0570173d12dc97012f5e@linux-foundation.org>
In-Reply-To: <6336c469-c946-c300-7392-87052c990266@suse.cz>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
	<84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
	<20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
	<8A6309F4-DB76-48FA-BE7F-BF9536A4C4E5@cs.rutgers.edu>
	<20170410180714.7yfnxl7qin72jcob@techsingularity.net>
	<20170410150903.f931ceb5475d2d3d8945bb71@linux-foundation.org>
	<789A2322-A5B6-4AC8-8668-D7057A56A140@cs.rutgers.edu>
	<6336c469-c946-c300-7392-87052c990266@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 11 Apr 2017 08:35:02 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> >> I have Kirrill's
> >>
> >> thp-reduce-indentation-level-in-change_huge_pmd.patch
> >> thp-fix-madv_dontneed-vs-numa-balancing-race.patch
> >> mm-drop-unused-pmdp_huge_get_and_clear_notify.patch
> >> thp-fix-madv_dontneed-vs-madv_free-race.patch
> >> thp-fix-madv_dontneed-vs-madv_free-race-fix.patch
> >> thp-fix-madv_dontneed-vs-clear-soft-dirty-race.patch
> >>
> >> scheduled for 4.12-rc1.  It sounds like
> >> thp-fix-madv_dontneed-vs-madv_free-race.patch and
> >> thp-fix-madv_dontneed-vs-madv_free-race.patch need to be boosted to
> >> 4.11 and stable?
> > 
> > thp-fix-madv_dontneed-vs-numa-balancing-race.patch is the fix for
> > numa balancing problem reported in this thread.
> > 
> > mm-drop-unused-pmdp_huge_get_and_clear_notify.patch,
> > thp-fix-madv_dontneed-vs-madv_free-race.patch,
> > thp-fix-madv_dontneed-vs-madv_free-race-fix.patch, and
> > thp-fix-madv_dontneed-vs-clear-soft-dirty-race.patch
> > 
> > are the fixes for other potential race problems similar to this one.
> > 
> > I think it is better to have all these patches applied.
> 
> Yeah we should get all such fixes to stable IMHO (after review :). It's
> not the first time that a fix for MADV_DONTNEED turned out to also fix a
> race that involved "normal operation" with THP, without such syscalls.

The presence of thp-reduce-indentation-level-in-change_huge_pmd.patch
is a pain in the ass but I've decided to keep it rather than churning
all the patches at a late stage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

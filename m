Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 288026B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:16:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so20291094wmw.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:16:53 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id q124si4297404wmg.96.2015.11.13.01.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 01:16:53 -0800 (PST)
Received: by wmvv187 with SMTP id v187so71540204wmv.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:16:53 -0800 (PST)
Date: Fri, 13 Nov 2015 10:16:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: get rid of __alloc_pages_high_priority
Message-ID: <20151113091651.GA2632@dhcp22.suse.cz>
References: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511121245430.10324@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511121245430.10324@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 12-11-15 12:47:45, David Rientjes wrote:
> On Thu, 12 Nov 2015, mhocko@kernel.org wrote:
[...]
> > Hi,
> > I think that this is more a cleanup than any functional change. We
> > are rarely screwed so much that __alloc_pages_high_priority would
> > fail. Yet I think that __alloc_pages_high_priority is obscuring the
> > overal intention more than it is helpful. Another motivation is to
> > reduce wait_iff_congested call to a single one in the allocator. I plan
> > to do other changes in that area and get rid of it altogether.
> 
> I think it's a combination of a cleanup (the inlining of 
> __alloc_pages_high_priority) and a functional change (no longer looping 
> infinitely around a get_page_from_freelist() call).  I'd suggest doing the 
> inlining in one patch and then the reworking of __GFP_NOFAIL when 
> ALLOC_NO_WATERMARKS fails just so we could easily revert the latter if 
> necessary.

I can split it up if this is really preferable of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

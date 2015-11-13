Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDA06B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 17:31:13 -0500 (EST)
Received: by pacej9 with SMTP id ej9so5810875pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:31:13 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id xm2si30084344pbb.66.2015.11.13.14.31.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 14:31:12 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so112838352pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:31:12 -0800 (PST)
Date: Fri, 13 Nov 2015 14:31:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: get rid of __alloc_pages_high_priority
In-Reply-To: <20151113091651.GA2632@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511131430430.3376@chino.kir.corp.google.com>
References: <1447343618-19696-1-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511121245430.10324@chino.kir.corp.google.com> <20151113091651.GA2632@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 13 Nov 2015, Michal Hocko wrote:

> > > Hi,
> > > I think that this is more a cleanup than any functional change. We
> > > are rarely screwed so much that __alloc_pages_high_priority would
> > > fail. Yet I think that __alloc_pages_high_priority is obscuring the
> > > overal intention more than it is helpful. Another motivation is to
> > > reduce wait_iff_congested call to a single one in the allocator. I plan
> > > to do other changes in that area and get rid of it altogether.
> > 
> > I think it's a combination of a cleanup (the inlining of 
> > __alloc_pages_high_priority) and a functional change (no longer looping 
> > infinitely around a get_page_from_freelist() call).  I'd suggest doing the 
> > inlining in one patch and then the reworking of __GFP_NOFAIL when 
> > ALLOC_NO_WATERMARKS fails just so we could easily revert the latter if 
> > necessary.
> 
> I can split it up if this is really preferable of course.

I think it's preferable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

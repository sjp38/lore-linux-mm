Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AF5FF6B0037
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 09:12:33 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id f8so7937826wiw.3
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 06:12:33 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id i1si3509446wja.94.2014.08.05.06.12.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 06:12:32 -0700 (PDT)
Date: Tue, 5 Aug 2014 09:12:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: avoid charge statistics churn during
 page migration
Message-ID: <20140805131223.GA14734@cmpxchg.org>
References: <1407184469-20741-1-git-send-email-hannes@cmpxchg.org>
 <20140805122434.GD15908@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140805122434.GD15908@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 05, 2014 at 02:24:34PM +0200, Michal Hocko wrote:
> On Mon 04-08-14 16:34:29, Johannes Weiner wrote:
> > Charge migration currently disables IRQs twice to update the charge
> > statistics for the old page and then again for the new page.
> > 
> > But migration is a seemless transition of a charge from one physical
> > page to another one of the same size, so this should be a non-event
> > from an accounting point of view.  Leave the statistics alone.
> 
> Moving stats to mem_cgroup_commit_charge sounds logical to me but does
> this work properly even for the fuse replace page cache case when old
> and new pages can already live in different memcgs?

We don't migrate if the new page is already charged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

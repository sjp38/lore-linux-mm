Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 98B036B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 09:34:51 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1351801wib.10
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 06:34:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si4739351wia.13.2014.08.05.06.34.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 06:34:38 -0700 (PDT)
Date: Tue, 5 Aug 2014 15:34:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: avoid charge statistics churn during
 page migration
Message-ID: <20140805133428.GH15908@dhcp22.suse.cz>
References: <1407184469-20741-1-git-send-email-hannes@cmpxchg.org>
 <20140805122434.GD15908@dhcp22.suse.cz>
 <20140805131223.GA14734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140805131223.GA14734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 05-08-14 09:12:23, Johannes Weiner wrote:
> On Tue, Aug 05, 2014 at 02:24:34PM +0200, Michal Hocko wrote:
> > On Mon 04-08-14 16:34:29, Johannes Weiner wrote:
> > > Charge migration currently disables IRQs twice to update the charge
> > > statistics for the old page and then again for the new page.
> > > 
> > > But migration is a seemless transition of a charge from one physical
> > > page to another one of the same size, so this should be a non-event
> > > from an accounting point of view.  Leave the statistics alone.
> > 
> > Moving stats to mem_cgroup_commit_charge sounds logical to me but does
> > this work properly even for the fuse replace page cache case when old
> > and new pages can already live in different memcgs?
> 
> We don't migrate if the new page is already charged.

Right you are.

Acked-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

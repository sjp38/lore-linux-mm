Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E22906B039C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:18:31 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b31-v6so3348263plb.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:18:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9-v6sor6098236pgo.273.2018.05.09.01.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 01:18:30 -0700 (PDT)
Date: Wed, 9 May 2018 17:18:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/memblock: print memblock_remove
Message-ID: <20180509081825.GA220810@rodete-desktop-imager.corp.google.com>
References: <20180508104223.8028-1-minchan@kernel.org>
 <20180509081214.GE32366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509081214.GE32366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, May 09, 2018 at 10:12:14AM +0200, Michal Hocko wrote:
> On Tue 08-05-18 19:42:23, Minchan Kim wrote:
> > memblock_remove report is useful to see why MemTotal of /proc/meminfo
> > between two kernels makes difference.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/memblock.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 5228f594b13c..03d48d8835ba 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -697,6 +697,11 @@ static int __init_memblock memblock_remove_range(struct memblock_type *type,
> >  
> >  int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
> >  {
> > +	phys_addr_t end = base + size - 1;
> > +
> > +	memblock_dbg("memblock_remove: [%pa-%pa] %pS\n",
> > +		     &base, &end, (void *)_RET_IP_);
> 
> Other callers of memblock_dbg use %pF. Is there any reason to be
> different here?

checkpatch hit me.

WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
#24: FILE: mm/memblock.c:702:
+       memblock_dbg("memblock_remove: [%pa-%pa] %pF\n",
+                    &base, &end, (void *)_RET_IP_);

> 
> Other that that looks ok to me.

Thanks, Michal.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9106B03CA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 09:11:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id g10so10617148wrg.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 06:11:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w75si4508986wrb.207.2017.03.08.06.11.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 06:11:11 -0800 (PST)
Date: Wed, 8 Mar 2017 15:11:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] s390: get rid of superfluous __GFP_REPEAT
Message-ID: <20170308141110.GL11028@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-2-mhocko@kernel.org>
 <20170308082340.GB12158@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308082340.GB12158@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 08-03-17 09:23:40, Heiko Carstens wrote:
> On Tue, Mar 07, 2017 at 04:48:40PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations.
> > 
> > page_table_alloc then uses the flag for a single page allocation. This
> > means that this flag has never been actually useful here because it has
> > always been used only for PAGE_ALLOC_COSTLY requests.
> > 
> > An earlier attempt to remove the flag 10d58bf297e2 ("s390: get rid of
> > superfluous __GFP_REPEAT") has missed this one but the situation is very
> > same here.
> > 
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  arch/s390/mm/pgalloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> FWIW:
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Thanks

> If you want, this can be routed via the s390 tree, whatever you prefer.

Yes, that would be great. I suspect the rest will take longer to get
merged or land to a conclusion.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

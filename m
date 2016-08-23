Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F26536B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:17:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so92599590lfw.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 02:17:28 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id re8si2158192wjb.225.2016.08.23.02.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 02:17:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q128so17186298wma.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 02:17:27 -0700 (PDT)
Date: Tue, 23 Aug 2016 11:17:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
Message-ID: <20160823091726.GK23577@dhcp22.suse.cz>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
 <20160823083830.GC15849@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823083830.GC15849@x4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 23-08-16 10:38:30, Markus Trippelsdorf wrote:
> On 2016.08.23 at 10:09 +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > The current wording of the COMPACTION Kconfig help text doesn't
> > emphasise that disabling COMPACTION might cripple the page allocator
> > which relies on the compaction quite heavily for high order requests and
> > an unexpected OOM can happen with the lack of compaction. Make sure
> > we are vocal about that.
> 
> Just a few nitpicks inline below:
> 
> >  mm/Kconfig | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 78a23c5c302d..0dff2f05b6d1 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -262,7 +262,14 @@ config COMPACTION
> >  	select MIGRATION
> >  	depends on MMU
> >  	help
> > -	  Allows the compaction of memory for the allocation of huge pages.
> > +          Compaction is the only memory management component to form
> > +          high order (larger physically contiguous) memory blocks
> > +          reliably. Page allocator relies on the compaction heavily and
>                        The page allo...      on compaction    
> > +          the lack of the feature can lead to unexpected OOM killer
> > +          invocation for high order memory requests. You shouldnm't
>              invocations                                    shouldn't  
> > +          disable this option unless there is really a strong reason for
>                                               really is      
> > +          it and then we are really interested to hear about that at
>                             would be    

Thanks for the review. Updated patch follows:
---

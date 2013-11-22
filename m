Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 552FB6B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:39:34 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id ca18so3327137wib.11
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:39:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e10si3429272wij.30.2013.11.22.15.39.32
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 15:39:33 -0800 (PST)
Date: Fri, 22 Nov 2013 18:39:28 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] mmzone.h: constify some zone access functions
Message-ID: <20131122183928.15941f0e@redhat.com>
In-Reply-To: <20131122143047.51b4fbe7aa227b8e37908106@linux-foundation.org>
References: <20131122120106.4c372847@redhat.com>
	<20131122143047.51b4fbe7aa227b8e37908106@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com

On Fri, 22 Nov 2013 14:30:47 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 22 Nov 2013 12:01:06 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
> > ---
> >  include/linux/mmzone.h | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index bd791e4..5e202d6 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -560,12 +560,12 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
> >  	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
> >  }
> >  
> > -static inline bool zone_is_initialized(struct zone *zone)
> > +static inline bool zone_is_initialized(const struct zone *zone)
> >  {
> >  	return !!zone->wait_table;
> >  }
> >  
> > -static inline bool zone_is_empty(struct zone *zone)
> > +static inline bool zone_is_empty(const struct zone *zone)
> >  {
> >  	return zone->spanned_pages == 0;
> >  }
> > @@ -843,7 +843,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
> >   */
> >  #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
> >  
> > -static inline int populated_zone(struct zone *zone)
> > +static inline int populated_zone(const struct zone *zone)
> >  {
> >  	return (!!zone->present_pages);
> >  }
> 
> hm, why?  I counted ten similarly constifyable functions in mm.h and
> stopped only 1/4 of the way through. What's so special about these three?

I spotted them while reading code. If you want to me convert the others,
I can do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

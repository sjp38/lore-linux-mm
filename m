Date: Wed, 5 Oct 2005 18:16:06 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
In-Reply-To: <1128531115.26009.32.camel@localhost>
Message-ID: <Pine.LNX.4.58.0510051815370.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
 <1128531115.26009.32.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Oct 2005, Dave Hansen wrote:

> On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> >
> > + */
> > +static inline struct free_area *
> > +fallback_buddy_reserve(int start_alloctype, struct zone *zone,
> > +                       unsigned int current_order, struct page *page,
> > +                       struct free_area *area)
> > +{
> > +       if (start_alloctype != RCLM_NORCLM)
> > +               return area;
> > +
> > +       area = &(zone->free_area_lists[RCLM_NORCLM][current_order]);
> > +
> > +       /* Reserve the whole block if this is a large split */
> > +       if (current_order >= MAX_ORDER / 2) {
> > +               int reserve_type=RCLM_NORCLM;
>
> -EBADCODINGSTYLE.
>

Changed to;

+static inline struct free_area *
+fallback_buddy_reserve(int start_alloctype, struct zone *zone,
+                       unsigned int current_order, struct page *page,
+                       struct free_area *area)
+{
+       int reserve_type;
+       if (start_alloctype != RCLM_NORCLM)
+               return area;
+
+       area = &(zone->free_area_lists[RCLM_NORCLM][current_order]);
+
+       /* Reserve the whole block if this is a large split */
+       if (current_order >= MAX_ORDER / 2) {
+               reserve_type=RCLM_NORCLM;

(Ignore the whitespace damage, cutting and pasting just so you can see it)

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

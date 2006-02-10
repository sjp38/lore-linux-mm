From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v22
Date: Fri, 10 Feb 2006 11:56:08 +1100
References: <200602092339.49719.kernel@kolivas.org> <43EBE3AB.1010009@jp.fujitsu.com>
In-Reply-To: <43EBE3AB.1010009@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602101156.09326.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Friday 10 February 2006 11:51, KAMEZAWA Hiroyuki wrote:
> Hi,
>
> Con Kolivas wrote:
> > +void add_to_swapped_list(struct page *page)
> > +{
> > +	struct swapped_entry *entry;
> > +	unsigned long index;
> > +
> > +	spin_lock(&swapped.lock);
> > +	if (swapped.count >= swapped.maxcount) {
>
> Assume x86 system with 8G memory, swapped_maxcount is maybe 5G+ here.
> Then, swapped_entry can consume 5G/PAGE_SIZE * 16bytes = 10 M byte more
> slabs from ZONE_NORMAL. Could you add check like this?
> ==
> void add_to_swapped_list(struct page *page)
> {
> 	<snip>
> 	if (!swap_prefetch)
> 		return;
> 	spin_lcok(&spwapped.lock);
> }
> ==

Sure why not. It made testing easier to not stop adding entries to the swapped 
list when it was disabled, but for release your idea makes sense. Thanks for 
the suggestion.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

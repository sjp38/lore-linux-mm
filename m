Date: Tue, 27 May 2008 04:28:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] lockless get_user_pages
Message-ID: <20080527022801.GB21578@wotan.suse.de>
References: <20080525145227.GC25747@wotan.suse.de> <8763t1w1ko.fsf@saeurebad.de> <20080527095519.4676.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080527095519.4676.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 09:57:11AM +0900, KOSAKI Motohiro wrote:
> > > Introduce a new "fast_gup" (for want of a better name right now)
> > 
> > Perhaps,
> > 
> >   * get_address_space
> >   * get_address_mappings
> >   * get_mapped_pages
> >   * get_page_mappings
> > 
> > Or s@get_@ref_@?
> 
> Why get_user_pages_lockless() is wrong?
> or get_my_pages() is better?
> (because this method assume task is current task)

Aw, nobody likes fast_gup? ;)

Technically get_user_pages_lockless is wrong: the implementation may
not be lockless so one cannot assume it will not take mmap sem and
ptls.

But I do like to make it clear that it is related to get_user_pages.
get_current_user_pages(), maybe? Hmm, that's harder to grep for
both then I guess. get_user_pages_current?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

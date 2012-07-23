Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 41DEF6B0068
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:34:54 -0400 (EDT)
Date: Mon, 23 Jul 2012 11:35:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120723023510.GB6832@bbox>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718054824.GA32341@bbox>
 <20120720194858.GA16249@t510.redhat.com>
 <20120723023332.GA6832@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120723023332.GA6832@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Rafael Aquini <aquini@linux.com>

On Mon, Jul 23, 2012 at 11:33:32AM +0900, Minchan Kim wrote:
> Hi Rafael,
> 
> On Fri, Jul 20, 2012 at 04:48:59PM -0300, Rafael Aquini wrote:
> > Howdy Minchan,
> > 
> > Once again, thanks for raising such valuable feedback over here.
> > 
> > On Wed, Jul 18, 2012 at 02:48:24PM +0900, Minchan Kim wrote:
> > > > +/* __isolate_lru_page() counterpart for a ballooned page */
> > > > +static bool isolate_balloon_page(struct page *page)
> > > > +{
> > > > +	if (WARN_ON(!is_balloon_page(page)))
> > > > +		return false;
> > > 
> > > I am not sure we need this because you alreay check it before calling
> > > isolate_balloon_page. If you really need it, it would be better to
> > > add likely in isolate_balloon_page, too.
> > > 
> > 
> > This check point was set in place because isolate_balloon_page() was a publicly
> > visible function and while our current usage looks correct it would not hurt to
> > have something like that done -- think of it as an insurance policy, in case
> > someone else, in the future, attempts to use it on any other place outside this
> > specifc context. 
> > Despite not seeing it as a dealbreaker for the patch as is, I do agree, however,
> > this snippet can _potentially_ be removed from isolate_balloon_page(), since
> > this function has become static to compaction.c.
> 
> Yes. It's not static.

Typo. It's static.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

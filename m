Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 5A7356B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:31:47 -0400 (EDT)
Date: Tue, 3 Jul 2012 15:31:36 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120703183135.GE1727@t510.redhat.com>
References: <cover.1340916058.git.aquini@redhat.com>
 <d0f33a6492501a0d420abbf184f9b956cff3e3fc.1340916058.git.aquini@redhat.com>
 <4FED3DDB.1000903@kernel.org>
 <20120629173653.GA1774@t510.redhat.com>
 <20120629220333.GA2079@barrios>
 <20120630013447.GA1545@x61.redhat.com>
 <4FF0DEE2.5080200@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF0DEE2.5080200@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jul 02, 2012 at 08:36:02AM +0900, Minchan Kim wrote:
> On 06/30/2012 10:34 AM, Rafael Aquini wrote:
> 
> >> void isolate_page_from_balloonlist(struct page* page)
> >> > {
> >> > 	page->mapping->a_ops->invalidatepage(page, 0);
> >> > }
> >> > 
> >> > 	if (is_balloon_page(page) && (page_count(page) == 2)) {
> >> > 		isolate_page_from_balloonlist(page);
> >> > 	}
> >> > 
> > Humm, my feelings on your approach here: just an unecessary indirection that
> > doesn't bring the desired code readability improvement.
> > If the header comment statement on balloon_mapping->a_ops is not clear enough 
> > on those methods usage for ballooned pages:
> > 
> > ..... 
> > /*
> >  * Balloon pages special page->mapping.
> >  * users must properly allocate and initialize an instance of balloon_mapping,
> >  * and set it as the page->mapping for balloon enlisted page instances.
> >  *
> >  * address_space_operations necessary methods for ballooned pages:
> >  *   .migratepage    - used to perform balloon's page migration (as is)
> >  *   .invalidatepage - used to isolate a page from balloon's page list
> >  *   .freepage       - used to reinsert an isolated page to balloon's page list
> >  */
> > struct address_space *balloon_mapping;
> > EXPORT_SYMBOL_GPL(balloon_mapping);
> > .....
> > 
> > I can add an extra commentary, to recollect folks about that usage, next to the
> > points where those callbacks are used at isolate_balloon_page() &
> > putback_balloon_page(). What do you think?
> > 
> > 
> 
> 
> I am not strongly against you.
> It trivial nitpick must not prevent your great work. :)
> 
> Thanks!
> 
>
Nah, I'm the one who should be thanking everyone else here. :)

After a second thought I decided to follow your suggestion on this one as well.
Soon, I'll be posting the re-spin

Thanks Minchan!

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

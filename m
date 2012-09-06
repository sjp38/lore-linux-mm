Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EC4AC6B00A8
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 22:17:36 -0400 (EDT)
Date: Thu, 6 Sep 2012 11:19:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm: use get_page_migratetype instead of page_private
Message-ID: <20120906021909.GC31615@bbox>
References: <1346829962-31989-1-git-send-email-minchan@kernel.org>
 <1346829962-31989-2-git-send-email-minchan@kernel.org>
 <50480447.4030007@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50480447.4030007@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kame,

On Thu, Sep 06, 2012 at 11:02:47AM +0900, Kamezawa Hiroyuki wrote:
> (2012/09/05 16:26), Minchan Kim wrote:
> > page allocator uses set_page_private and page_private for handling
> > migratetype when it frees page. Let's replace them with [set|get]
> > _page_migratetype to make it more clear.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Hmm. one request from me.
> 
> > ---
> >   include/linux/mm.h  |   10 ++++++++++
> >   mm/page_alloc.c     |   11 +++++++----
> >   mm/page_isolation.c |    2 +-
> >   3 files changed, 18 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 5c76634..86d61d6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -249,6 +249,16 @@ struct inode;
> >   #define page_private(page)		((page)->private)
> >   #define set_page_private(page, v)	((page)->private = (v))
> >   
> > +static inline void set_page_migratetype(struct page *page, int migratetype)
> > +{
> > +	set_page_private(page, migratetype);
> > +}
> > +
> > +static inline int get_page_migratetype(struct page *page)
> > +{
> > +	return page_private(page);
> > +}
> > +
> 
> Could you add comments to explain "when this function returns expected value" ?
> These functions can work well only in very restricted area of codes.

Yes. It works only if the page exist in free_list.
I will add the comment about that and hope change function name
get_page_migratetype with get_buddypage_migratetype.
It would be less confusing.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

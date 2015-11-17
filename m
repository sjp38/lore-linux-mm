Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id A291C6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:20:11 -0500 (EST)
Received: by oixx65 with SMTP id x65so82650375oix.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:20:11 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id az5si23741752obb.70.2015.11.16.18.20.09
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 18:20:10 -0800 (PST)
Date: Tue, 17 Nov 2015 10:18:56 +0800
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH 4/7] mm/vmscan: page_is_file_cache can be boolean
Message-ID: <20151117021856.GB5867@yaowei-K42JY>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-5-git-send-email-baiyaowei@cmss.chinamobile.com>
 <alpine.DEB.2.10.1511160209060.18751@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511160209060.18751@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 16, 2015 at 02:10:10AM -0800, David Rientjes wrote:
> On Mon, 16 Nov 2015, Yaowei Bai wrote:
> 
> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> > index cf55945..af73135 100644
> > --- a/include/linux/mm_inline.h
> > +++ b/include/linux/mm_inline.h
> > @@ -8,8 +8,8 @@
> >   * page_is_file_cache - should the page be on a file LRU or anon LRU?
> >   * @page: the page to test
> >   *
> > - * Returns 1 if @page is page cache page backed by a regular filesystem,
> > - * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
> > + * Returns true if @page is page cache page backed by a regular filesystem,
> > + * or false if @page is anonymous, tmpfs or otherwise ram or swap backed.
> >   * Used by functions that manipulate the LRU lists, to sort a page
> >   * onto the right LRU list.
> >   *
> > @@ -17,7 +17,7 @@
> >   * needs to survive until the page is last deleted from the LRU, which
> >   * could be as far down as __page_cache_release.
> >   */
> > -static inline int page_is_file_cache(struct page *page)
> > +static inline bool page_is_file_cache(struct page *page)
> >  {
> >  	return !PageSwapBacked(page);
> >  }
> 
> Since page_is_file_cache() is often used to determine which zlc to 
> increment or decrement (usage such as 
> NR_ISOLATED_ANON + page_is_file_cache(page)), I don't think this style is 
> helpful.

Yes, you'r right, we can drop this one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 9 Jan 2008 13:26:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 03/19] define page_file_cache() function
Message-Id: <20080109132615.8fbaef05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080108172856.4196bd4b@bree.surriel.com>
References: <20080108205939.323955454@redhat.com>
	<20080108205959.952424899@redhat.com>
	<Pine.LNX.4.64.0801081414230.4281@schroedinger.engr.sgi.com>
	<20080108172856.4196bd4b@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008 17:28:56 -0500
Rik van Riel <riel@redhat.com> wrote:

> On Tue, 8 Jan 2008 14:18:40 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 8 Jan 2008, Rik van Riel wrote:
> > 
> > > Define page_file_cache() function to answer the question:
> > > 	is page backed by a file?
> > 
> > > +static inline int page_file_cache(struct page *page)
> > > +{
> > > +	if (PageSwapBacked(page))
> > > +		return 0;
> > 
> > Could we call this PageNotFileBacked or so? PageSwapBacked is true for 
> > pages that are RAM based. Its a bit confusing.
> 
> PageNotFileBacked confuses me a little, since shared memory segments live
> in tmpfs and are kinda sorta file backed, but go to swap instead of to a
> filesystem when there is memory pressure.
> 
How about PageIsNotCache() ? :)

When a page is a cache, there is an original data somewhere and can be dropped
out.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

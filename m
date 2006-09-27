Date: Wed, 27 Sep 2006 02:19:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Get rid of zone_table V2
Message-Id: <20060927021934.9461b867.akpm@osdl.org>
In-Reply-To: <20060924030643.e57f700c.akpm@osdl.org>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
	<20060924030643.e57f700c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2006 03:06:43 -0700
Andrew Morton <akpm@osdl.org> wrote:

> On Mon, 18 Sep 2006 12:21:35 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> >  static inline int page_zone_id(struct page *page)
> >  {
> > -	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
> > -}
> > -static inline struct zone *page_zone(struct page *page)
> > -{
> > -	return zone_table[page_zone_id(page)];
> > +	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
> >  }
> 
> arm allmodconfig:
> 
> include/linux/mm.h: In function `page_zone_id':
> include/linux/mm.h:450: warning: right shift count >= width of type

ping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

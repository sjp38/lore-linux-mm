Date: Thu, 30 Nov 2006 09:38:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to
 userspace
Message-Id: <20061130093838.4ad6b301.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830611291625uf599963k7e6ff351c2b73e34@mail.gmail.com>
References: <20061129030655.941148000@menage.corp.google.com>
	<20061129033826.268090000@menage.corp.google.com>
	<20061130091815.018f52fd.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830611291625uf599963k7e6ff351c2b73e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006 16:25:22 -0800
"Paul Menage" <menage@google.com> wrote:

> On 11/29/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 28 Nov 2006 19:06:56 -0800
> > menage@google.com wrote:
> >
> > >
> > > +     for (i = 0; i < pgdat->node_spanned_pages; ++i) {
> > > +             struct page *page = pgdat_page_nr(pgdat, i);
> > you need pfn_valid() check before accessing page struct.
> 
> OK. (That check can only fail if CONFIG_SPARSEMEM, right?)
> 
No, ia64's virtual memmap will fail too.

> >
> >
> > > +             if (!isolate_lru_page(page, &pagelist)) {
> > you'll see panic if !PageLRU(page).
> 
> In which kernel version? In 2.6.19-rc6 (also -mm1) there's no panic in
> isolate_lru_page().
> 

Sorry, my mistake. I checked isolate_lru_pages() (><

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

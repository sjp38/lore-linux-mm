Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id kAU0PO42027782
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 16:25:25 -0800
Received: from nf-out-0910.google.com (nfeb2.prod.google.com [10.48.154.2])
	by zps75.corp.google.com with ESMTP id kAU0PMQo010244
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 16:25:23 -0800
Received: by nf-out-0910.google.com with SMTP id b2so2889267nfe
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 16:25:22 -0800 (PST)
Message-ID: <6599ad830611291625uf599963k7e6ff351c2b73e34@mail.gmail.com>
Date: Wed, 29 Nov 2006 16:25:22 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <20061130091815.018f52fd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <20061130091815.018f52fd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/29/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 28 Nov 2006 19:06:56 -0800
> menage@google.com wrote:
>
> >
> > +     for (i = 0; i < pgdat->node_spanned_pages; ++i) {
> > +             struct page *page = pgdat_page_nr(pgdat, i);
> you need pfn_valid() check before accessing page struct.

OK. (That check can only fail if CONFIG_SPARSEMEM, right?)

>
>
> > +             if (!isolate_lru_page(page, &pagelist)) {
> you'll see panic if !PageLRU(page).

In which kernel version? In 2.6.19-rc6 (also -mm1) there's no panic in
isolate_lru_page().

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

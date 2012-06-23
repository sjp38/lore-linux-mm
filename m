Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3D9DD6B0287
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 22:59:14 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1501287vcb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 19:59:13 -0700 (PDT)
Message-ID: <4FE530F7.1060108@gmail.com>
Date: Fri, 22 Jun 2012 22:59:03 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org> <4FE2FCFB.4040808@jp.fujitsu.com> <4FE3C4E4.2050107@kernel.org> <4FE414A2.3000700@kernel.org>
In-Reply-To: <4FE414A2.3000700@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


One more.


> +/*
> + * NOTE:
> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) direclty.
> + * Instead, use {un}set_pageblock_isolate.
> + */
>  void set_pageblock_migratetype(struct page *page, int migratetype)
>  {
>         if (unlikely(page_group_by_mobility_disabled))

I don't think we need this comment. please just add BUG_ON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F5356B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 04:49:11 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M8n8np003235
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Oct 2010 17:49:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 50CD845DE52
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 17:49:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AB745DE4F
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 17:49:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC0791DB8017
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 17:49:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FC621DB8015
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 17:49:07 +0900 (JST)
Date: Fri, 22 Oct 2010 17:43:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Message-Id: <20101022174343.cf474ab3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTik9p3U-oUPC=KrUbd5iBWgEGJYKx8bHcWNkUCuE@mail.gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-2-git-send-email-lliubbo@gmail.com>
	<20101022121610.2c380b0b.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik9p3U-oUPC=KrUbd5iBWgEGJYKx8bHcWNkUCuE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010 16:41:13 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> On Fri, Oct 22, 2010 at 11:16 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 21 Oct 2010 21:28:20 +0800
> > Bob Liu <lliubbo@gmail.com> wrote:
> >
> >> If not_managed is true all pages will be putback to lru, so
> >> break the loop earlier to skip other pages isolate.
> >>
> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >
> > please don't skip dump_page().
> >
> 
> Hi, Kame
> 
> I put the check after dump_page() in order to we can still see the
> dump message if the loop is broken earlier.
> 
> Thanks
> 

Ah, sorry. I misunderstood.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

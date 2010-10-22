Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E73636B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 23:18:32 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M3IHF9009562
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Oct 2010 12:18:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 341D345DE57
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:18:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E4F545DE4E
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:18:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E40EF1DB805B
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:18:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A0E0E1DB803F
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:18:16 +0900 (JST)
Date: Fri, 22 Oct 2010 12:12:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] page_isolation: codeclean fix comment and rm
 unneeded val init
Message-Id: <20101022121214.7ec6ec3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 21:28:19 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> function __test_page_isolated_in_pageblock() return 1 if all pages
> in the range is isolated, so fix the comment.
> value pfn will be init in the following loop so rm it.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

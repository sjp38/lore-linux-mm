Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 91F1860044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 18:51:50 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o03NpmMD011000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 08:51:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F331845DE4F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:51:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1C1245DE4C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:51:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B4CDA1DB8038
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:51:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E566E18001
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:51:47 +0900 (JST)
Date: Mon, 4 Jan 2010 08:48:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
Message-Id: <20100104084838.fd229ec0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228164451.A687.A69D9226@jp.fujitsu.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 16:47:22 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> The zone->lock is one of performance critical locks. Then, it shouldn't
> be hold for long time. Currently, we have four walk_zones_in_node()
> usage and almost use-case don't need to hold zone->lock.
> 
> Thus, this patch move locking responsibility from walk_zones_in_node
> to its sub function. Also this patch kill unnecessary zone->lock taking.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

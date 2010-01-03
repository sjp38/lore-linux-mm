Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A541060044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 18:50:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o03NoBh4010341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 08:50:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E71D45DE4F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:50:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC31C45DE4E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:50:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9CB1DB8040
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:50:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 468851DB803F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:50:10 +0900 (JST)
Date: Mon, 4 Jan 2010 08:47:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] vmstat: add anon_scan_ratio field to zoneinfo
Message-Id: <20100104084701.6e8d7f12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228164816.A68D.A69D9226@jp.fujitsu.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
	<20091228164816.A68D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 16:48:51 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Vmscan folks was asked "why does my system makes so much swap-out?"
> in lkml at several times.
> At that time, I made the debug patch to show recent_anon_{scanned/rorated}
> parameter at least three times.
> 
> Thus, its parameter should be showed on /proc/zoneinfo. It help
> vmscan folks debugging.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

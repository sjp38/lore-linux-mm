Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F9CA6B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 22:23:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B2NfWg002783
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 11:23:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5127645DD78
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:23:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1282E45DD80
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:23:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C50D61DB8045
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:23:40 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 712B91DB8038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:23:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.31 -mm merge plans
In-Reply-To: <20090610115140.09c9f4cb.akpm@linux-foundation.org>
References: <20090610115140.09c9f4cb.akpm@linux-foundation.org>
Message-Id: <20090611112031.5918.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 11:23:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> vmscan-drop-pf_swapwrite-from-zone_reclaim.patch
> vmscan-zone_reclaim-use-may_swap.patch

Could you please hold those zone-reclaim related patches a while?
zone reclaim is under disccusion with Mel and Wu now.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

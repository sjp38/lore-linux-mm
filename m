Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 51AA16B01FE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:30:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D1UaBv001418
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 10:30:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4732A45DE5D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:30:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 23AED45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:30:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F3BE08003
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:30:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A119EE08001
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:30:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <4BBF9B34.5040909@redhat.com>
References: <20100409142057.be0ce5af.akpm@linux-foundation.org> <4BBF9B34.5040909@redhat.com>
Message-Id: <20100413102641.4A18.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 13 Apr 2010 10:30:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On 04/09/2010 05:20 PM, Andrew Morton wrote:
> 
> > Come to that, it's not obvious that we need this in 2.6.34 either.  What
> > is the user-visible impact here?
> 
> I suspect very little impact, especially during workloads
> where we can just reclaim clean page cache at DEF_PRIORITY.
> FWIW, the patch looks good to me, so:
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> 

I'm surprised this ack a bit. Rik, do you have any improvement plan about
streaming io detection logic?
I think the patch have a slightly marginal benefit, it help to <1% scan
ratio case. but it have big regression, it cause streaming io (e.g. backup
operation) makes tons swap.

So, I thought we sould do either,
1) drop this one
2) merge to change stream io detection logic improvement at first, and
   merge this one at second.

Am i missing something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

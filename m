Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A95E36B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 05:13:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n319DN1l017394
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Apr 2009 18:13:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A47BB45DD76
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:13:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8269C45DD74
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:13:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7FC1DB8018
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:13:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 418461DB8016
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:13:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: add_to_swap_cache with GFP_ATOMIC ?
In-Reply-To: <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
References: <Pine.LNX.4.64.0903311154570.19028@blonde.anvils> <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
Message-Id: <20090401181236.B1F4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Apr 2009 18:13:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> IOW, GFP_ATOMIC on add_to_swap() was introduced accidentally. the reason 
> was old add_to_page_cache() didn't have gfp_mask parameter and we didn't
>  have the reason of changing add_to_swap() behavior.
> I think it don't have deeply reason and changing GFP_NOIO don't cause regression.

"accidentally" is wrong word obiously. I mean "non strong intention".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

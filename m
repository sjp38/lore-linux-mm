Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CDDB6B02A3
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 04:43:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6O8htKD006070
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 24 Jul 2010 17:43:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C804445DE50
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:43:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 895A745DE4C
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:43:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5695DE08002
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:43:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6201DB8015
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:43:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: VFS scalability git tree
In-Reply-To: <20100722190100.GA22269@amd>
References: <20100722190100.GA22269@amd>
Message-Id: <20100724174038.3C96.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 24 Jul 2010 17:43:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> At this point, I would be very interested in reviewing, correctness
> testing on different configurations, and of course benchmarking.

I haven't review this series so long time. but I've found one misterious
shrink_slab() usage. can you please see my patch? (I will send it as
another mail)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

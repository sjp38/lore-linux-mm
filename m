Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CCFB66B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 20:42:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M1gEgq015777
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Jan 2010 10:42:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 56E9F45DE4E
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:42:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 31E3045DE4F
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:42:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 117201DB8040
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:42:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B63BE1DB803C
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 10:42:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
In-Reply-To: <20100122100155.6C03.A69D9226@jp.fujitsu.com>
References: <201001212121.50272.rjw@sisk.pl> <20100122100155.6C03.A69D9226@jp.fujitsu.com>
Message-Id: <20100122103830.6C09.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 22 Jan 2010 10:42:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > Probably we have multiple option. but I don't think GFP_NOIO is good
> > > option. It assume the system have lots non-dirty cache memory and it isn't
> > > guranteed.
> > 
> > Basically nothing is guaranteed in this case.  However, does it actually make
> > things _worse_?  
> 
> Hmm..
> Do you mean we don't need to prevent accidental suspend failure?
> Perhaps, I did misunderstand your intention. If you think your patch solve
> this this issue, I still disagree. but If you think your patch mitigate
> the pain of this issue, I agree it. I don't have any reason to oppose your
> first patch.

One question. Have anyone tested Rafael's $subject patch? 
Please post test result. if the issue disapper by the patch, we can
suppose the slowness is caused by i/o layer.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

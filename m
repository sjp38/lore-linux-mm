Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DBBA46B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:52:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G3qnxp014334
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 12:52:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C0145DE51
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:52:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 54DFE45DE4F
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:52:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 313F61DB8044
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:52:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A51A61DB804C
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:52:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Export amount of anonymous memory in a mapping via smaps
In-Reply-To: <201009160856.25923.knikanth@suse.de>
References: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009160856.25923.knikanth@suse.de>
Message-Id: <20100916125147.CA08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 16 Sep 2010 12:52:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Export the number of anonymous pages in a mapping via smaps.
> 
> Even the private pages in a mapping backed by a file, would be marked as
> anonymous, when they are modified. Export this information to user-space via
> smaps.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77E176B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 22:36:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G2aHnp028426
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Sep 2009 11:36:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F16CF45DE52
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:36:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D016645DE4F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:36:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B29961DB8037
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:36:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF551DB8038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:36:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Isolated(anon) and Isolated(file)
In-Reply-To: <20090915191957.9e901c38.akpm@linux-foundation.org>
References: <20090916091022.DB8C.A69D9226@jp.fujitsu.com> <20090915191957.9e901c38.akpm@linux-foundation.org>
Message-Id: <20090916112608.DB95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Sep 2009 11:36:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 16 Sep 2009 11:09:54 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] Kill Isolated field in /proc/meminfo fix
> > 
> > Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> > It is only increased at heavy memory pressure case.
> 
> Have we made up our minds yet?
> 
> Below is what remains.  Please check that the changelog is still
> accurate and complete.  If not, please send along a new one?

Oh, great. I think that's correct.
Thanks!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

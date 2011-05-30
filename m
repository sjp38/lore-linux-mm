Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52A2F6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 03:44:24 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C1D593EE0B5
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:44:21 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ABCA745DEC7
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:44:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94DB045DEC5
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:44:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 885F01DB803B
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:44:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 549331DB802F
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:44:21 +0900 (JST)
Message-ID: <4DE34AD0.1060905@jp.fujitsu.com>
Date: Mon, 30 May 2011 16:44:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] vmscan,memcg: memcg aware swap token
References: <4DD480DD.2040307@jp.fujitsu.com> <20110526133551.8c158f1c.akpm@linux-foundation.org>
In-Reply-To: <20110526133551.8c158f1c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

> CONFIG_CGROUPS=n:
> 
> mm/thrash.c: In function 'grab_swap_token':
> mm/thrash.c:73: error: implicit declaration of function 'css_put'
> 
> I don't think that adding a null stub for css_put() is the right fix
> here...

My bad. Following patch fixes this issue.

Thanks.

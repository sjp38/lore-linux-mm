Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9798A6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:50:50 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF0omMo015080
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 09:50:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 681BA45DE52
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:50:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B26945DE4F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:50:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 097F61DB8043
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:50:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BA45A1DB803F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:50:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] mm: Give up allocation if the task have fatal signal
In-Reply-To: <20091215085455.13eb65cc.minchan.kim@barrios-desktop>
References: <20091214213224.BBC6.A69D9226@jp.fujitsu.com> <20091215085455.13eb65cc.minchan.kim@barrios-desktop>
Message-Id: <20091215094659.CDB8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 09:50:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >  	/*
> > +	 * If the allocation is for userland page and we have fatal signal,
> > +	 * there isn't any reason to continue allocation. instead, the task
> > +	 * should exit soon.
> > +	 */
> > +	if (fatal_signal_pending(current) && (gfp_mask & __GFP_HIGHMEM))
> > +		goto nopage;
> 
> If we jump nopage, we meets dump_stack and show_mem. 
> Even, we can meet OOM which might kill innocent process.

Which point you oppose? noprint is better?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

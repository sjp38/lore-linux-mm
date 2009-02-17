Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 76D226B00D8
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 19:09:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1H09hPD019718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Feb 2009 09:09:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 007D045DD84
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:09:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C13C645DD78
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:09:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E6021DB8040
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:09:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C1AF1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 09:09:42 +0900 (JST)
Date: Tue, 17 Feb 2009 09:08:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix vmaccnt at fork (Was Re: "heuristic overcommit" and
 fork())
Message-Id: <20090217090829.4adf3e70.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090216143231.GB16153@csn.ul.ie>
References: <ED3886372DB5491AAA799709DBA78F6F@david>
	<20090213103655.3a0ea204.kamezawa.hiroyu@jp.fujitsu.com>
	<20090216143231.GB16153@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, David CHAMPELOVIER <david@champelovier.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2009 14:32:32 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> >  #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
> >  
> >  #if !defined(CONFIG_ARCH_POPULATES_NODE_MAP) && \
> > 
> > 
> 
> NAK.
> 
Ok, I'm wrong. thanks.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

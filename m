Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D6C805F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 19:58:00 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3GNwrfU011417
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 08:58:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 986AF45DD7B
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 08:58:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 785CF45DD78
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 08:58:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60B111DB8038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 08:58:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10FA01DB803B
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 08:58:53 +0900 (JST)
Date: Fri, 17 Apr 2009 08:57:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090417085720.1fc8cc86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090416121407.GH7082@balbir.in.ibm.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416121407.GH7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Apr 2009 17:44:07 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-16 16:40:36]:
> 
> > 2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
> > (Because it's file cache, pc->mem_cgroup is not NULL always.)
> > 
> > I saw this very easily.
> > ==
> > Cache: 4096
> > mapped_file: 20480
> > ==
> >
> 
> May I ask how and what was expected?
>  

Mapped_file <= Cache,

Thanks,
-Kame


> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

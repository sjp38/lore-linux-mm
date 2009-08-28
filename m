Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC75A6B0092
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:03:47 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7SG3gq0020069
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 21:33:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SG3gdr1802370
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 21:33:42 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7SG3fk8012587
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 21:33:42 +0530
Date: Fri, 28 Aug 2009 21:33:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] memcg: uncharge in batched manner
Message-ID: <20090828160340.GU4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com> <20090828151011.GS4889@balbir.in.ibm.com> <b9c52b465bda540da8dbcd434bff55be.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <b9c52b465bda540da8dbcd434bff55be.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-29 00:21:50]:

> > tof unmap_vmas, exit_mmap, etc so that we don't have to keep
> > additional data structures around.
> >
> We can't. We uncharge when page->mapcount goes down to 0.
> This is unknown until page_remove_rmap() decrement page->mapcount
> by "atomic" ops.
> 
> My first version allocated memcg_batch_info on stack ...and..
> I had to pass an extra argument to page_remove_rmap() etc....
> That was very ugly ;(
> Now, I adds per-task memcg_batch_info to task struct.
> Because it will be always used at exit() and make exit() path
> much faster, it's not very costly.
>

Aaah.. I see that makes a lot of sense. Thanks for the clarification. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 642726B02AA
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:42:36 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6SESImK024436
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:28:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6SEgXiU126150
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:42:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6SEgWJ4005148
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 10:42:32 -0400
Date: Wed, 28 Jul 2010 20:12:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/7][memcg] towards I/O aware memory cgroup
Message-ID: <20100728144229.GD14369@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-07-27 16:51:55]:

> 
> From a view of patch management, this set is a mixture of a few features for
> memcg, and I should divide them to some groups. But, at first, I'd like to
> show the total view. This set is consists from 5 sets. Main purpose is
> create a room in page_cgroup for I/O tracking and add light-weight access method
> for file-cache related accounting. 
> 
> 1.   An virtual-indexed array.
> 2,3. Use virtual-indexed array for id-to-memory_cgroup detection.
> 4.   modify page_cgroup to use ID instead of pointer, this gives us enough
>      spaces for further memory tracking.

Yes, this is good, I've been meaning to merge the flags and the
pointer. Thanks for looking into this.

> 5,6   Use light-weight locking mechanism for file related accounting.
> 7.   use spin_lock instead of bit_spinlock.
> 
> 
> As a function,  patch 5,6 can be an independent patch and I'll accept
> reordering series of patch if someone requests.
> But we'll need all, I think.
> (irq_save for patch 7 will be required later.)
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

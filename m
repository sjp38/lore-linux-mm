Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 169E86B02A3
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:18:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S0II3h025966
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 09:18:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13DC445DE52
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:18:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD7F345DE4D
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:18:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E7571DB8045
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:18:17 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B4A71DB803E
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:18:17 +0900 (JST)
Date: Wed, 28 Jul 2010 09:13:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7][memcg] towards I/O aware memory cgroup
Message-Id: <20100728091330.b8197d15.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 16:51:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
> 5,6   Use light-weight locking mechanism for file related accounting.
> 7.   use spin_lock instead of bit_spinlock.
> 
> 
> As a function,  patch 5,6 can be an independent patch and I'll accept
> reordering series of patch if someone requests.
> But we'll need all, I think.
> (irq_save for patch 7 will be required later.)
> 
> Any comments are welcome.
> 

This was onto mmotm-0719..but mmotm-0727 is shipped. I'll post rebased one
if someone wants to test.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

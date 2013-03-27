Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 902EE6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 01:16:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 96C6A3EE0BB
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:16:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7934745DDCF
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:16:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FE645DE56
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:16:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 376FB1DB8040
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:16:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5051DB8044
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:16:14 +0900 (JST)
Message-ID: <5152807D.5010905@jp.fujitsu.com>
Date: Wed, 27 Mar 2013 14:15:41 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: remove swapcache page early
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1364350932-12853-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>

(2013/03/27 11:22), Minchan Kim wrote:
> Swap subsystem does lazy swap slot free with expecting the page
> would be swapped out again so we can't avoid unnecessary write.
> 
> But the problem in in-memory swap is that it consumes memory space
> until vm_swap_full(ie, used half of all of swap device) condition
> meet. It could be bad if we use multiple swap device, small in-memory swap
> and big storage swap or in-memory swap alone.
> 
> This patch changes vm_swap_full logic slightly so it could free
> swap slot early if the backed device is really fast.
> For it, I used SWP_SOLIDSTATE but It might be controversial.
> So let's add Ccing Shaohua and Hugh.
> If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> or something for z* family.
> 
> Other problem is zram is block device so that it can set SWP_INMEMORY
> or SWP_SOLIDSTATE easily(ie, actually, zram is already done) but
> I have no idea to use it for frontswap.
> 
> Any idea?
> 
Another thinking....in what case, in what system configuration, 
vm_swap_full() should return false and delay swp_entry freeing ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

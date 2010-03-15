Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BE5296B0194
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 22:30:45 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F2UgFB001685
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 11:30:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D6FF45DE55
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:30:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 269B445DE50
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:30:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 09C53E08003
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:30:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 299531DB8013
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:30:41 +0900 (JST)
Date: Mon, 15 Mar 2010 11:26:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100315112657.02e476e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268609202-15581-5-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-5-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 00:26:41 +0100
Andrea Righi <arighi@develer.com> wrote:

> Infrastructure to account dirty pages per cgroup and add dirty limit
> interfaces in the cgroupfs:
> 
>  - Direct write-out: memory.dirty_ratio, memory.dirty_bytes
> 
>  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

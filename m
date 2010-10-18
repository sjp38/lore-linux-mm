Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AC9F45F0047
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 20:58:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I0wv08026755
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 09:58:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EFEA45DE70
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:58:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2562345DE60
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:58:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C012EF8001
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:58:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5601EEF8005
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:58:56 +0900 (JST)
Date: Mon, 18 Oct 2010 09:53:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 09/11] memcg: add cgroupfs interface to memcg dirty
 limits
Message-Id: <20101018095331.37633910.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287177279-30876-10-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-10-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2010 14:14:37 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add cgroupfs interface to memcg dirty page limits:
>   Direct write-out is controlled with:
>   - memory.dirty_ratio
>   - memory.dirty_limit_in_bytes
> 
>   Background write-out is controlled with:
>   - memory.dirty_background_ratio
>   - memory.dirty_background_limit_bytes
> 
> Other memcg cgroupfs files support 'M', 'm', 'k', 'K', 'g'
> and 'G' suffixes for byte counts.  This patch provides the
> same functionality for memory.dirty_limit_in_bytes and
> memory.dirty_background_limit_bytes.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

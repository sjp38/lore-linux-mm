Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 97C886B01AF
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 02:09:25 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5769M7V017847
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 7 Jun 2010 15:09:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3746945DE5B
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:09:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EEA4345DE4F
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:09:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D63771DB805E
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:09:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 846431DB803C
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:09:21 +0900 (JST)
Date: Mon, 7 Jun 2010 15:05:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [cleanup][PATCH -mmotm 2/2] memcg: remove mem from arg of
 charge_common
Message-Id: <20100607150506.2c3c9a38.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100607145337.c0b5ad79.nishimura@mxp.nes.nec.co.jp>
References: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
	<20100607145337.c0b5ad79.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2010 14:53:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> mem_cgroup_charge_common() is always called with @mem = NULL, so it's
> meaningless. This patch removes it.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hioryuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

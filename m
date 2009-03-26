Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 034BA6B003D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 23:50:49 -0400 (EDT)
Date: Thu, 26 Mar 2009 13:31:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326133108.8e2cadb8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 13:08:21 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> This is another bug I've working on recently.
> 
> I want this (and the stale swapcache problem) to be fixed for 2.6.30.
> 
> Any comments?
> 
Ah, you need cache_charge cleanup patch to apply this patch.

  http://marc.info/?l=linux-mm&m=123778534632443&w=2


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

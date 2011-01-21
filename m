Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE1E8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 02:26:56 -0500 (EST)
Date: Fri, 21 Jan 2011 16:16:07 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 1/7] memcg : comment, style fixes for recent patch of
 move_parent
Message-Id: <20110121161607.9b54e525.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 15:37:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> A fix for 987eba66e0e6aa654d60881a14731a353ee0acb4
> 
> A clean up for mem_cgroup_move_parent(). 
>  - remove unnecessary initialization of local variable.
>  - rename charge_size -> page_size
>  - remove unnecessary (wrong) comment.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

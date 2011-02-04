Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 340F18D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:06:15 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D31F73EE0BC
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:06:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA6D945DE59
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:06:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2A2245DE56
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:06:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9669CE08002
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:06:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 635491DB8037
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:06:12 +0900 (JST)
Date: Fri, 4 Feb 2011 09:00:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add memcg sanity checks at allocating and
 freeing pages
Message-Id: <20110204090008.20c9f049.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203141533.GH2286@cmpxchg.org>
References: <20110203141533.GH2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 15:15:33 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> This patch add checks at allocating or freeing a page whether the page is used
> (iow, charged) from the view point of memcg.
> 
> This check may be useful in debugging a problem and we did similar checks
> before the commit 52d4b9ac(memcg: allocate all page_cgroup at boot).
> 
> This patch adds some overheads at allocating or freeing memory, so it's enabled
> only when CONFIG_DEBUG_VM is enabled.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

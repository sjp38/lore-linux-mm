Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CF5D78D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:57:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 854453EE0B5
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:57:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D0FB45DE55
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:57:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 528E145DE56
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:57:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40CCBE18002
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:57:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B584E08002
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:57:54 +0900 (JST)
Date: Thu, 10 Feb 2011 08:51:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/4] memcg: keep only one charge cancelling function
Message-Id: <20110210085145.9873fd18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297249313-23746-2-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
	<1297249313-23746-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 12:01:50 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> We have two charge cancelling functions: one takes a page count, the
> other a page size.  The second one just divides the parameter by
> PAGE_SIZE and then calls the first one.  This is trivial, no need for
> an extra function.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

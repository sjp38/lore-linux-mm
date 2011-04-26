Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 819EB9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 04:57:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5F72B3EE081
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:56:58 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B3045DE92
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:56:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30C4345DE76
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:56:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 22AA1E08002
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:56:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E42CC1DB8037
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:56:57 +0900 (JST)
Date: Tue, 26 Apr 2011 17:50:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: (resend) [PATCH] vmscan,memcg: memcg aware swap token
Message-Id: <20110426175021.c783e57d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110426170146.F396.A69D9226@jp.fujitsu.com>
References: <20110426170146.F396.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>

On Tue, 26 Apr 2011 16:59:19 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Currently, memcg reclaim can disable swap token even if the swap token
> mm doesn't belong in its memory cgroup. It's slightly riskly. If an
> admin makes very small mem-cgroup and silly guy runs contenious heavy
> memory pressure workloa, whole tasks in the system are going to lose
> swap-token and then system may become unresponsive. That's bad.
> 
> This patch adds 'memcg' parameter into disable_swap_token(). and if
> the parameter doesn't match swap-token, VM doesn't put swap-token.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Ack. Thank you.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

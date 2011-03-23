Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C62D78D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 19:44:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F129E3EE0BC
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:44:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBE5945DE4E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:44:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCA445DE61
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:44:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF34C1DB803A
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:44:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70DDA1DB803C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:44:03 +0900 (JST)
Date: Thu, 24 Mar 2011 08:37:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: move page-freeing code out of lock
Message-Id: <20110324083709.d9c9cb75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1300881558-13523-1-git-send-email-namhyung@gmail.com>
References: <20110323133614.95553de8.kamezawa.hiroyu@jp.fujitsu.com>
	<1300881558-13523-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

On Wed, 23 Mar 2011 20:59:18 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> Move page-freeing code out of swap_cgroup_mutex in the hope that it
> could reduce few of theoretical contentions between swapons and/or
> swapoffs.
> 
> This is just a cleanup, no functional changes.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: Paul Menage <menage@google.com>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: containers@lists.linux-foundation.org

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

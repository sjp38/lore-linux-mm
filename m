Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4D7398D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 18:52:32 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BAA203EE0B5
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:52:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FB0645DE57
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:52:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 87F5345DE5A
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:52:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7910E1DB8038
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:52:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45746E08004
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:52:29 +0900 (JST)
Date: Fri, 4 Feb 2011 08:46:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: remove unused page flag bitfield defines
Message-Id: <20110204084625.b8c40f24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203141000.GE2286@cmpxchg.org>
References: <20110203141000.GE2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 15:10:00 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> These definitions have been unused since '4b3bde4 memcg: remove the
> overhead associated with the root cgroup'.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I tried to remove this but finally I didn't. It seems there will be
no objections for this time.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B2A056B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:16:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6286A3EE0BD
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:16:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D9E45DEEA
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:16:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B60545DEDA
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:16:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE4C1DB803C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:16:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CEDFC1DB8038
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:16:37 +0900 (JST)
Date: Wed, 21 Dec 2011 09:15:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] memcg: cleanup for_each_node_state()
Message-Id: <20111221091526.2adde75e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324375312-31252-1-git-send-email-lliubbo@gmail.com>
References: <1324375312-31252-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org

On Tue, 20 Dec 2011 18:01:52 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> We already have for_each_node(node) define in nodemask.h, better to use it.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

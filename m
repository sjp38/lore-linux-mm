Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B2F076B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 19:52:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E22DA3EE0BB
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:52:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5E9045DE52
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:52:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB87145DE4D
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:52:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98D761DB8041
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:52:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D2961DB803F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:52:16 +0900 (JST)
Date: Mon, 5 Dec 2011 09:51:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] page_cgroup: add helper function to get swap_cgroup
Message-Id: <20111205095107.74f742b8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
References: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, jweiner@redhat.com, bsingharora@gmail.com

On Fri, 2 Dec 2011 18:40:27 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> There are multi places need to get swap_cgroup, so add a helper
> function:
> static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
>                                 struct swap_cgroup_ctrl **ctrl);
> to simple the code.
> 
> v1 -> v2:
>  - add parameter struct swap_cgroup_ctrl **ctrl suggested by Michal
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

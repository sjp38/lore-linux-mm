Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id BA0A06B0068
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 05:02:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E5EDE3EE081
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:02:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D071745DE58
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:02:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B949A45DE54
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:02:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACF531DB803A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:02:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 620661DB803C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:02:27 +0900 (JST)
Message-ID: <507BD10B.8010608@jp.fujitsu.com>
Date: Mon, 15 Oct 2012 18:02:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: make mem_cgroup_out_of_memory static
References: <alpine.DEB.2.00.1210111307220.28062@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210111307220.28062@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

(2012/10/12 5:09), David Rientjes wrote:
> mem_cgroup_out_of_memory() is only referenced from within file scope, so
> it can be marked static.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

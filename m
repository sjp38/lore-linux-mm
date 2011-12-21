Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E998F6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:19:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9431F3EE0B6
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:19:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78C0E45DEEC
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:19:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D97E45DEEA
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:19:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E92E61DB803C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:19:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FAF21DB8038
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:19:29 +0900 (JST)
Date: Wed, 21 Dec 2011 09:18:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] page_cgroup: drop multi CONFIG_MEMORY_HOTPLUG
Message-Id: <20111221091819.8d1f8e55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324375421-31358-1-git-send-email-lliubbo@gmail.com>
References: <1324375421-31358-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org

On Tue, 20 Dec 2011 18:03:41 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> No need two CONFIG_MEMORY_HOTPLUG place.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

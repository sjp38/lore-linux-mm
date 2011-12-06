Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7E6D26B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 05:13:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 834A13EE0C1
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:13:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EFE645DEAD
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:13:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E57A45DEA6
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:13:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F90E1DB803C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:13:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5BCC1DB803E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:13:37 +0900 (JST)
Date: Tue, 6 Dec 2011 19:12:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/4] memcg: simplify page cache charging
Message-Id: <20111206191211.3be32ccb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

This is an add-on patches to mem_cgroup_replace_page_cache(), introducing
new LRU rule under memcg, finally. After this, lru handling will be
much simplified. (all pathces are based on 3.2.0-rc4-next-20111205+)

But this is experimental... I may forget some important corner cases.
==

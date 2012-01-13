Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4274F6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:46:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B80213EE0C0
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:46:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9056645DE61
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:46:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 768DB45DE4E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:46:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 650CF1DB8041
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:46:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09EF41DB803E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:46:23 +0900 (JST)
Date: Fri, 13 Jan 2012 17:45:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 7/7 v2] memcg: make mem_cgroup_begin_update_stat to
 use global pcpu.
Message-Id: <20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>


Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 07D846B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:33:47 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 298CB3EE0C1
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:33:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D56A45DE5B
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:33:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E716D45DE5A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:33:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D2D95E0800D
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:33:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88AEDE08008
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:33:44 +0900 (JST)
Date: Fri, 13 Jan 2012 17:32:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 1/7 v2] memcg: remove unnecessary check in
 mem_cgroup_update_page_stat()
Message-Id: <20120113173227.df2baae3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>


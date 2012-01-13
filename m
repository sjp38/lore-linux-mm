Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3ECD96B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:42:53 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA9533EE0B5
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:42:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B082645DE4E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:42:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AC2645DE4F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:42:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EF841DB8040
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:42:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3881E1DB8037
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:42:51 +0900 (JST)
Date: Fri, 13 Jan 2012 17:41:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 4/7 v2] memcg: new scheme to update per-memcg page
 stat accounting.
Message-Id: <20120113174138.ec7b64d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>


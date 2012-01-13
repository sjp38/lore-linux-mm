Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A58196B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:35:04 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 32E583EE0C8
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:35:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1461345DE6D
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:35:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C06F745DE67
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:35:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A76EB1DB8044
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:35:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A8A41DB803E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 17:35:02 +0900 (JST)
Date: Fri, 13 Jan 2012 17:33:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking account
 move.
Message-Id: <20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

I think this bugfix is needed before going ahead. thoughts?
==

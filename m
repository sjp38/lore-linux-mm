Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id F15AC6B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:09:04 -0500 (EST)
Date: Thu, 3 Jan 2013 19:09:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -repost] memcg,vmscan: do not break out targeted reclaim
 without reclaimed pages
Message-ID: <20130103180901.GA22067@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,
I have posted this quite some time ago
(https://lkml.org/lkml/2012/12/14/102) but it probably slipped through
---

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 75C2A6B0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 03:51:11 -0500 (EST)
Date: Tue, 29 Jan 2013 09:51:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mmotm:
 memcgvmscan-do-not-break-out-targeted-reclaim-without-reclaimed-pages.patch
 fix
Message-ID: <20130129085104.GA30322@dhcp22.suse.cz>
References: <20130103180901.GA22067@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130103180901.GA22067@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>

Ying has noticed me (via private email) that the patch is bogus because
the break out condition is incorrect. She said she would post a fix
but she's been probably too busy. If she doesn't oppose, could you add
the follow up fix, please?

I am really sorry about this mess.
---

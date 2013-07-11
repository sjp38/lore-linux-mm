Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id DF9556B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:33:02 -0400 (EDT)
Date: Thu, 11 Jul 2013 11:33:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] vmpressure: make sure memcg stays alive until all users
 are signaled
Message-ID: <20130711093300.GE21667@dhcp22.suse.cz>
References: <20130710184254.GA16979@mtj.dyndns.org>
 <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DE7AAF.6070004@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

OK, here we go with v2. Thanks a lot for catching up issues Li!
I am also CCing other memcg guys and linux-mm.
---

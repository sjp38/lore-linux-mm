Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 69A3C6B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:49:37 -0400 (EDT)
Date: Fri, 19 Oct 2012 15:49:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/6] memcg: make mem_cgroup_reparent_charges non failing
Message-ID: <20121019134934.GG799@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-6-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350480648-10905-6-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

This is an updated version of the patch. I have dropped
.__DEPRECATED_clear_css_refs in this one as it makes the best sense to
me. I didn't add Tejun's Reviewed-by because of this change. Could you
recheck, please?
---

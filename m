Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8BBEC6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 13:10:14 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id bv4so1096453qab.8
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 10:10:13 -0700 (PDT)
Date: Mon, 5 Aug 2013 13:10:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 5/5] memcg: rename cgroup_event to mem_cgroup_event
Message-ID: <20130805171008.GC23751@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <1375632446-2581-6-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375632446-2581-6-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


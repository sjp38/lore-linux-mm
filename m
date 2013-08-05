Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 539576B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 13:09:42 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id f11so1110642qae.10
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 10:09:41 -0700 (PDT)
Date: Mon, 5 Aug 2013 13:09:28 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 3/5] cgroup, memcg: move cgroup_event implementation to
 memcg
Message-ID: <20130805170928.GB23751@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <1375632446-2581-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375632446-2581-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


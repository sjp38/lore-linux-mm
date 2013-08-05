Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id F14016B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 13:08:39 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id s11so1816101qcv.34
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 10:08:39 -0700 (PDT)
Date: Mon, 5 Aug 2013 13:08:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 2/5] cgroup: make __cgroup_from_dentry() and
 __cgroup_dput() global
Message-ID: <20130805170834.GA23751@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <1375632446-2581-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375632446-2581-3-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


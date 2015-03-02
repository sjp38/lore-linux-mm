Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id F07E06B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:13:01 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id e89so12025638qgf.10
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:13:01 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id u1si12196483qak.19.2015.03.02.09.13.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:13:01 -0800 (PST)
Received: by mail-qg0-f50.google.com with SMTP id e89so25960307qgf.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:13:01 -0800 (PST)
Date: Mon, 2 Mar 2015 12:12:57 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] cgroup: call cgroup_subsys->bind on cgroup subsys
 initialization
Message-ID: <20150302171257.GL17694@htj.duckdns.org>
References: <131af5f5ee0eec55d0f94a785db4be04baf01f51.1424356325.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <131af5f5ee0eec55d0f94a785db4be04baf01f51.1424356325.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 19, 2015 at 05:34:46PM +0300, Vladimir Davydov wrote:
> Currently, we call cgroup_subsys->bind only on unmount, remount, and
> when creating a new root on mount. Since the default hierarchy root is
> created in cgroup_init, we will not call cgroup_subsys->bind if the
> default hierarchy is freshly mounted. As a result, some controllers will
> behave incorrectly (most notably, the "memory" controller will not
> enable hierarchy support). Fix this by calling cgroup_subsys->bind right
> after initializing a cgroup subsystem.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Applied to cgroup/for-4.0-fixes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

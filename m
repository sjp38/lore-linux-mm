Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 57D556B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:15:30 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so4777048qcx.4
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:15:30 -0800 (PST)
Received: from mail-gg0-x230.google.com (mail-gg0-x230.google.com [2607:f8b0:4002:c02::230])
        by mx.google.com with ESMTPS id k3si14381890qao.170.2013.12.17.05.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:15:29 -0800 (PST)
Received: by mail-gg0-f176.google.com with SMTP id l12so59703gge.7
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:15:28 -0800 (PST)
Date: Tue, 17 Dec 2013 08:15:25 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH cgroup/for-3.13-fixes] cgroup: don't recycle cgroup id until
 all csses' have been destroyed
Message-ID: <20131217131525.GH29989@htj.dyndns.org>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFC163.5010507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hey,

I updated the comment myself and applied the patch to
cgroup/for-3.13-fixes.

Thanks!
-------- 8< --------

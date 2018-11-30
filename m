Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8C56B59C7
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:18:24 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v74so6237878qkb.21
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 11:18:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor6198128qvr.12.2018.11.30.11.18.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 11:18:23 -0800 (PST)
Date: Fri, 30 Nov 2018 11:18:19 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181130191819.GJ2509588@devbig004.ftw2.facebook.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz

Hello,

On Mon, Nov 05, 2018 at 11:55:45AM -0500, Daniel Jordan wrote:
> Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> ktask threads now run at the lowest priority on the system to avoid disturbing
> busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> The plan to address your other comments is explained below.

Have you tested what kind of impact this has on bandwidth of a system
in addition to latency?  The thing is while this would make a better
use of a system which has idle capacity, it does so by doing more
total work.  It'd be really interesting to see how this affects
bandwidth of a system too.

Thanks.

-- 
tejun

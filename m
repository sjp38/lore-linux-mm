Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id E94D86B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:56:03 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id l123so122700852ywe.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:56:03 -0700 (PDT)
Received: from mail-yb0-x22b.google.com (mail-yb0-x22b.google.com. [2607:f8b0:4002:c09::22b])
        by mx.google.com with ESMTPS id 197si8342882ybd.164.2017.05.24.10.56.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:56:03 -0700 (PDT)
Received: by mail-yb0-x22b.google.com with SMTP id 130so29152201ybl.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:56:02 -0700 (PDT)
Date: Wed, 24 May 2017 13:56:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
Message-ID: <20170524175600.GL24798@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
 <20170519205550.GD15279@wtj.duckdns.org>
 <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
 <20170524173144.GI24798@htj.duckdns.org>
 <29bc746d-f89b-3385-fd5c-314bcd22f9f7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29bc746d-f89b-3385-fd5c-314bcd22f9f7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Wed, May 24, 2017 at 01:49:46PM -0400, Waiman Long wrote:
> What I am saying is as follows:
>     / A
> P - B
>    \ C
> 
> # echo +memory > P/cgroups.subtree_control
> # echo -memory > P/A/cgroup.controllers
> # echo "#memory" > P/B/cgroup.controllers
> 
> The parent grants the memory controller to its children - A, B and C.
> Child A has the memory controller explicitly disabled. Child B has the
> memory controller in pass-through mode, while child C has the memory
> controller enabled by default. "echo +memory > cgroup.controllers" is
> not allowed. There are 2 possible choices with regard to the '-' or '#'
> prefixes. We can allow them before the grant from the parent or only
> after that. In the former case, the state remains dormant until after
> the grant from the parent.

Ah, I see, you want cgroup.controllers to be able to mask available
controllers by the parent.  Can you expand your example with further
nesting and how #memory on cgroup.controllers would affect the nested
descendant?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

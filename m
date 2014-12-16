Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 745076B0070
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 11:59:28 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so14317503wiv.2
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:59:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r5si2261452wjy.74.2014.12.16.08.59.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 08:59:27 -0800 (PST)
Date: Tue, 16 Dec 2014 11:59:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Provide knob for force OOM into the memcg
Message-ID: <20141216165922.GA30984@phnom.home.cmpxchg.org>
References: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: mhocko@suse.cz, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 16, 2014 at 06:55:35PM +0530, Chintan Pandya wrote:
> We may want to use memcg to limit the total memory
> footprint of all the processes within the one group.
> This may lead to a situation where any arbitrary
> process cannot get migrated to that one  memcg
> because its limits will be breached. Or, process can
> get migrated but even being most recently used
> process, it can get killed by in-cgroup OOM. To
> avoid such scenarios, provide a convenient knob
> by which we can forcefully trigger OOM and make
> a room for upcoming process.

Why do you move tasks around during runtime?  Rather than scanning
thousands or millions of page table entries to relocate a task and its
private memory to another configuration domain, wouldn't it be easier to
just keep the task in a dedicated cgroup and reconfigure that instead?

There doesn't seem to be a strong usecase for charge migration that
couldn't be solved by doing things slightly differently from userspace.
Certainly not something that justifies the complexity that it adds to
memcg model and it's synchronization requirements from VM hotpaths.
Hence, I'm inclined to not add charge moving to version 2 of memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

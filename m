Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40BDE6B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:54:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so6873976wre.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:54:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 98si4278301wrk.281.2017.10.02.14.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:54:49 -0700 (PDT)
Date: Mon, 2 Oct 2017 14:54:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] mm: only dispaly online cpus of the numa node
Message-Id: <20171002145446.eade11c1f28d55e5f67aa4d0@linux-foundation.org>
In-Reply-To: <20171002103806.GB3823@arm.com>
References: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com>
	<1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
	<20171002103806.GB3823@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>

On Mon, 2 Oct 2017 11:38:07 +0100 Will Deacon <will.deacon@arm.com> wrote:

> > When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
> > and display cpumask_of_node for each node), but I got different result on
> > X86 and arm64. For each numa node, the former only displayed online CPUs,
> > and the latter displayed all possible CPUs. Unfortunately, both Linux
> > documentation and numactl manual have not described it clear.
> > 
> > I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
> > that he preferred to print online cpus because it doesn't really make much
> > sense to bind anything on offline nodes.
> > 
> > Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  drivers/base/node.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> Which tree is this intended to go through? I'm happy to take it via arm64,
> but I don't want to tread on anybody's toes in linux-next and it looks like
> there are already queued changes to this file via Andrew's tree.

I grabbed it.  I suppose there's some small risk of userspace breakage
so I suggest it be a 4.15-rc1 thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

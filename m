Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B70C36B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 09:56:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v13so11287218pgq.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 06:56:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h71si386377pfh.339.2017.10.03.06.56.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 06:56:34 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:56:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm: only dispaly online cpus of the numa node
Message-ID: <20171003135628.xqhvr3rg7s5aymeq@dhcp22.suse.cz>
References: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com>
 <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
 <20171002103806.GB3823@arm.com>
 <20171002145446.eade11c1f28d55e5f67aa4d0@linux-foundation.org>
 <20171003134726.GC26552@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003134726.GC26552@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhen Lei <thunder.leizhen@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>

On Tue 03-10-17 14:47:26, Will Deacon wrote:
> On Mon, Oct 02, 2017 at 02:54:46PM -0700, Andrew Morton wrote:
> > On Mon, 2 Oct 2017 11:38:07 +0100 Will Deacon <will.deacon@arm.com> wrote:
> > 
> > > > When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
> > > > and display cpumask_of_node for each node), but I got different result on
> > > > X86 and arm64. For each numa node, the former only displayed online CPUs,
> > > > and the latter displayed all possible CPUs. Unfortunately, both Linux
> > > > documentation and numactl manual have not described it clear.
> > > > 
> > > > I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
> > > > that he preferred to print online cpus because it doesn't really make much
> > > > sense to bind anything on offline nodes.
> > > > 
> > > > Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> > > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > > ---
> > > >  drivers/base/node.c | 12 ++++++++++--
> > > >  1 file changed, 10 insertions(+), 2 deletions(-)
> > > 
> > > Which tree is this intended to go through? I'm happy to take it via arm64,
> > > but I don't want to tread on anybody's toes in linux-next and it looks like
> > > there are already queued changes to this file via Andrew's tree.
> > 
> > I grabbed it.  I suppose there's some small risk of userspace breakage
> > so I suggest it be a 4.15-rc1 thing?
> 
> To be honest, I suspect the vast majority (if not all) code that reads this
> file was developed for x86, so having the same behaviour for arm64 sounds
> like something we should do ASAP before people try to special case with
> things like #ifdef __aarch64__.
> 
> I'd rather have this in 4.14 if possible.

Agreed!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

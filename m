Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB32D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:35:44 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l20-v6so61033oii.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:35:44 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e11-v6si6437123otc.373.2018.06.19.08.35.43
        for <linux-mm@kvack.org>;
        Tue, 19 Jun 2018 08:35:43 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
	<20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
	<20180611145330.GO13364@dhcp22.suse.cz>
	<87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
	<87bmce60y3.fsf@e105922-lin.cambridge.arm.com>
	<8b715082-14d4-f10b-d2d6-b23be7e4bf7e@huawei.com>
	<20180619120714.GE13685@dhcp22.suse.cz>
	<874lhz3pmn.fsf@e105922-lin.cambridge.arm.com>
	<20180619140818.GA16927@e107981-ln.cambridge.arm.com>
	<87wouu3jz1.fsf@e105922-lin.cambridge.arm.com>
	<20180619151425.GH13685@dhcp22.suse.cz>
Date: Tue, 19 Jun 2018 16:35:40 +0100
In-Reply-To: <20180619151425.GH13685@dhcp22.suse.cz> (Michal Hocko's message
	of "Tue, 19 Jun 2018 17:14:25 +0200")
Message-ID: <87r2l23i2b.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Xie XiuQi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Bjorn Helgaas <helgaas@kernel.org>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 19-06-18 15:54:26, Punit Agrawal wrote:
> [...]
>> In terms of $SUBJECT, I wonder if it's worth taking the original patch
>> as a temporary fix (it'll also be easier to backport) while we work on
>> fixing these other issues and enabling memoryless nodes.
>
> Well, x86 already does that but copying this antipatern is not really
> nice. So it is good as a quick fix but it would be definitely much
> better to have a robust fix. Who knows how many other places might hit
> this. You certainly do not want to add a hack like this all over...

Completely agree! I was only suggesting it as a temporary measure,
especially as it looked like a proper fix might be invasive.

Another fix might be to change the node specific allocation to node
agnostic allocations. It isn't clear why the allocation is being
requested from a specific node. I think Lorenzo suggested this in one of
the threads.

I've started putting together a set fixing the issues identified in this
thread. It should give a better idea on the best course of action.

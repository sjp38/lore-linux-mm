Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4896B000C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:21:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o15-v6so6689711wmf.1
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:21:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24-v6si652987edm.168.2018.06.12.08.20.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jun 2018 08:20:59 -0700 (PDT)
Date: Tue, 12 Jun 2018 17:20:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180612152057.GA13364@dhcp22.suse.cz>
References: <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
 <20180607105514.GA13139@dhcp22.suse.cz>
 <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
 <20180607122152.GP32433@dhcp22.suse.cz>
 <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
 <20180611085237.GI13364@dhcp22.suse.cz>
 <16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
 <20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
 <20180611145330.GO13364@dhcp22.suse.cz>
 <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, Xie XiuQi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

On Tue 12-06-18 16:08:03, Punit Agrawal wrote:
> Michal Hocko <mhocko@kernel.org> writes:
[...]
> > Well, the standard way to handle memory less NUMA nodes is to simply
> > fallback to the closest NUMA node. We even have an API for that
> > (numa_mem_id).
> 
> CONFIG_HAVE_MEMORYLESS node is not enabled on arm64 which means we end
> up returning the original node in the fallback path.

Yes this makes more sense.
-- 
Michal Hocko
SUSE Labs

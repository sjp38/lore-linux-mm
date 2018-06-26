Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4A26B0008
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:27:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l20-v6so12429151oii.1
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:27:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i22-v6si678197ote.96.2018.06.26.10.27.04
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:27:04 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <20180619120714.GE13685@dhcp22.suse.cz>
	<874lhz3pmn.fsf@e105922-lin.cambridge.arm.com>
	<20180619140818.GA16927@e107981-ln.cambridge.arm.com>
	<87wouu3jz1.fsf@e105922-lin.cambridge.arm.com>
	<20180619151425.GH13685@dhcp22.suse.cz>
	<87r2l23i2b.fsf@e105922-lin.cambridge.arm.com>
	<20180619163256.GA18952@e107981-ln.cambridge.arm.com>
	<814205eb-ae86-a519-bed0-f09b8e2d3a02@huawei.com>
	<87602d3ccl.fsf@e105922-lin.cambridge.arm.com>
	<5c083c9c-473f-f504-848b-48506d0fd380@huawei.com>
	<20180622091153.GU10465@dhcp22.suse.cz>
	<87y3f7yv89.fsf@e105922-lin.cambridge.arm.com>
	<20180622184223.00007bc3@huawei.com>
Date: Tue, 26 Jun 2018 18:27:01 +0100
In-Reply-To: <20180622184223.00007bc3@huawei.com> (Jonathan Cameron's message
	of "Fri, 22 Jun 2018 18:42:23 +0100")
Message-ID: <87muvhwja2.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, tnowicki@caviumnetworks.com, Xie XiuQi <xiexiuqi@huawei.com>, linux-pci@vger.kernel.org, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <helgaas@kernel.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, Hanjun Guo <guohanjun@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, wanghuiqiang@huawei.com

Jonathan Cameron <jonathan.cameron@huawei.com> writes:

[...]

>
> I'll test it when back in the office, but I had a similar issue with
> memory only nodes when I moved the SRAT listing for cpus from the 4
> 4th mode to the 3rd node to fake some memory I could hot unplug.
> This gave a memory only node for the last node on the system.
>
> When I instead moved cpus from the 3rd node to the 4th (so the node
> with only memory was now in the middle, everything worked).
>
> Was odd, and I'd been meaning to chase it down but hadn't gotten to it
> yet.  If I get time I'll put together some test firmwares as see if there
> are any other nasty corner cases we aren't handling.

If you get a chance, it'd be really helpful to test reversing the
ordering of entries in the SRAT and booting with a restricted
NR_CPUS.

This issue was found through code inspection.

Please make sure to use the updated patch from Lorenzo for your
tests[0].

[0] https://marc.info/?l=linux-acpi&m=152998665713983&w=2

>
> Jonathan
>
>> 
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

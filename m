Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBAFC8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:26:37 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id h85so5580006oib.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:26:37 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v19si29117112oif.242.2019.01.10.10.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 10:26:36 -0800 (PST)
Date: Thu, 10 Jan 2019 18:26:10 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110182610.00004250@huawei.com>
In-Reply-To: <20190108145256.GX31793@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
	<20181227203158.GO16738@dhcp22.suse.cz>
	<20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
	<20181228084105.GQ16738@dhcp22.suse.cz>
	<20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
	<20181228121515.GS16738@dhcp22.suse.cz>
	<20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
	<20181228195224.GY16738@dhcp22.suse.cz>
	<20190102122110.00000206@huawei.com>
	<20190108145256.GX31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Mel Gorman  <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>," <linux-accelerators@lists.ozlabs.org>

On Tue, 8 Jan 2019 15:52:56 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> [...]
> > So ideally I'd love this set to head in a direction that helps me tick off
> > at least some of the above usecases and hopefully have some visibility on
> > how to address the others moving forwards,  
> 
> Is it sufficient to have such a memory marked as movable (aka only have
> ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> it fits the "balance by migration" concept.

Yes, to some degree. That's exactly what we are doing, though a things currently
stand I think you have to turn it on via a kernel command line and mark it
hotpluggable in ACPI. Given it my or may not actually be hotpluggable
that's less than elegant.

Let's randomly decide not to explore that one further for a few more weeks.
la la la la

If we have general balancing by migration then things are definitely
heading in a useful direction as long as 'hot' takes into account the
main user not being a CPU.  You are right that migration dealing with
the movable kernel allocations is a nice side effect though which I
hadn't thought about.  Long run we might end up with everything where
it should be after some level of burn in period. A generic version of
this proposal is looking nicer and nicer!

Thanks,

Jonathan

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72D1F8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:53:24 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so11116960qte.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:53:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n185si227214qke.100.2019.01.10.07.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 07:53:23 -0800 (PST)
Date: Thu, 10 Jan 2019 10:53:17 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110155317.GB4394@redhat.com>
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
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190108145256.GX31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-accelerators@lists.ozlabs.org

On Tue, Jan 08, 2019 at 03:52:56PM +0100, Michal Hocko wrote:
> On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> [...]
> > So ideally I'd love this set to head in a direction that helps me tick off
> > at least some of the above usecases and hopefully have some visibility on
> > how to address the others moving forwards,
> 
> Is it sufficient to have such a memory marked as movable (aka only have
> ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> it fits the "balance by migration" concept.

This would not work for GPU, GPU driver really want to be in total
control of their memory yet sometimes they want to migrate some part
of the process to their memory.

Cheers,
J�r�me

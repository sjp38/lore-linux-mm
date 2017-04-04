Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 042046B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 12:44:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u2so2589841wmu.18
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 09:44:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si20573238wmz.53.2017.04.04.09.44.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 09:44:57 -0700 (PDT)
Date: Tue, 4 Apr 2017 18:44:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170404164452.GQ15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 11:02:39, Reza Arbab wrote:
> On Tue, Apr 04, 2017 at 10:23:02AM +0200, Michal Hocko wrote:
> >diff --git a/drivers/base/node.c b/drivers/base/node.c
> >index 5548f9686016..ee080a35e869 100644
> >--- a/drivers/base/node.c
> >+++ b/drivers/base/node.c
> >@@ -368,8 +368,6 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
> >}
> >
> >#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> >-#define page_initialized(page)  (page->lru.next)
> >-
> >static int __ref get_nid_for_pfn(unsigned long pfn)
> >{
> >	struct page *page;
> >@@ -380,9 +378,6 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
> >	if (system_state == SYSTEM_BOOTING)
> >		return early_pfn_to_nid(pfn);
> >#endif
> >-	page = pfn_to_page(pfn);
> >-	if (!page_initialized(page))
> >-		return -1;
> >	return pfn_to_nid(pfn);
> >}
> >
> 
> You can get rid of 'page' altogether.
> 
> drivers/base/node.c: In function a??get_nid_for_pfna??:
> drivers/base/node.c:373:15: warning: unused variable a??pagea?? [-Wunused-variable]

Right, updated.

Thanks for your testing! This is highly appreciated.
Can I assume your Tested-by?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

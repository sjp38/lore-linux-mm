Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 051426B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:14:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so11273676wmf.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:14:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g42si20723267edc.110.2017.06.01.09.14.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 09:14:58 -0700 (PDT)
Date: Thu, 1 Jun 2017 18:14:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
Message-ID: <20170601161453.GA12764@dhcp22.suse.cz>
References: <20170601122004.32732-1-mhocko@kernel.org>
 <20170601160227.uioluvgvjtplesjr@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601160227.uioluvgvjtplesjr@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 01-06-17 11:02:28, Reza Arbab wrote:
> On Thu, Jun 01, 2017 at 02:20:04PM +0200, Michal Hocko wrote:
> >Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
> >movable_node is enabled and the range doesn't overlap with the existing
> >normal zone. This should provide a reasonable default onlining strategy.
> 
> I like it. If your distro has some auto-onlining udev rule like
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
> 
> You could get things onlined as movable just by putting movable_node in
> the boot params, without changing/modifying the rule.

yes this is the primary point of the patch ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

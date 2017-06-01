Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7156F6B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:38:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k15so11036138wmh.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:38:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g39si18499035edg.71.2017.06.01.08.38.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 08:38:44 -0700 (PDT)
Date: Thu, 1 Jun 2017 17:38:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
Message-ID: <20170601153838.GA8088@dhcp22.suse.cz>
References: <20170601122004.32732-1-mhocko@kernel.org>
 <820164f3-8bef-7761-0695-88db9e0ce7a7@suse.cz>
 <20170601142227.GF9091@dhcp22.suse.cz>
 <20170601151935.m5jbfmugocc66qfq@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601151935.m5jbfmugocc66qfq@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 01-06-17 10:19:36, Reza Arbab wrote:
> On Thu, Jun 01, 2017 at 04:22:28PM +0200, Michal Hocko wrote:
> >On Thu 01-06-17 16:11:55, Vlastimil Babka wrote:
> >>Simple should work, hopefully.
> >>- if memory is hotplugged, it's obviously hotplugable, so we don't have
> >>to rely on BIOS description.
> >
> >Not sure I understand. We do not have any information about the hotplug
> >status at the time we do online.
> 
> The x86 SRAT (or the dt, on other platforms) can describe memory as
> hotpluggable. See memblock_mark_hotplug(). That's only for memory present at
> boot, though.

Yes but lose that information after the memblock is gone and numa fully
initialized. Or can we reconstruct that somehow?

> He's saying that since the memory was added after boot, it is by definition
> hotpluggable. There's no need to check for that marking/description.

Yes, but we do not know whether we are onlining memblocks from a boot
time numa node or a fresh one which has been hotadded.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4276B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 05:23:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e68so493023wme.10
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 02:23:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m204si23595560wma.86.2017.04.05.02.23.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 02:23:15 -0700 (PDT)
Date: Wed, 5 Apr 2017 11:23:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/6] mm: get rid of zone_is_initialized
Message-ID: <20170405092311.GF6035@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-2-mhocko@kernel.org>
 <20170331073954.GF27098@dhcp22.suse.cz>
 <20170405081400.GE6035@dhcp22.suse.cz>
 <20170405110654.6ef458ee@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405110654.6ef458ee@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 05-04-17 11:06:54, Igor Mammedov wrote:
> On Wed, 5 Apr 2017 10:14:00 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 31-03-17 09:39:54, Michal Hocko wrote:
> > > Fixed screw ups during the initial patch split up as per Hillf
> > > ---
> > > From 8be6c5e47de66210e47710c80e72e8abd899017b Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Wed, 29 Mar 2017 15:11:30 +0200
> > > Subject: [PATCH] mm: get rid of zone_is_initialized
> > > 
> > > There shouldn't be any reason to add initialized when we can tell the
> > > same thing from checking whether there are any pages spanned to the
> > > zone. Remove zone_is_initialized() and replace it by zone_is_empty
> > > which can be used for the same set of tests.
> > > 
> > > This shouldn't have any visible effect  
> > 
> > I've decided to drop this patch. My main motivation was to simplify
> > the hotplug workflow/ The situation is more hairy than I expected,
> > though. On one hand all zones should be initialized early during the
> > hotplug in add_memory_resource but direct users of arch_add_memory will
> > need this to be called I suspect. Let's just keep the current status quo
> > and clean up it later. It is not really needed for this series.
> Would you post v2 with all fixups you've done so far?

yes, but I would like to sort what Reza Arbab is seeing first. I have
pushed my current changes to [1] for others to have something to play
with

[1] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git attempts/rewrite-mem_hotplug-WIP
branch. Please note I might rebase it later

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A61FC6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:48:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i18so14444661wrb.21
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:48:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 138si2124651wmx.13.2017.03.30.23.48.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 23:48:24 -0700 (PDT)
Date: Fri, 31 Mar 2017 08:48:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: get rid of zone_is_initialized
Message-ID: <20170331064821.GB27098@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-2-mhocko@kernel.org>
 <04a601d2a9d0$5ace0ab0$106a2010$@alibaba-inc.com>
 <20170331064301.GA27098@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331064301.GA27098@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Zhang Zhen' <zhenzhang.zhang@huawei.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 31-03-17 08:43:01, Michal Hocko wrote:
> On Fri 31-03-17 11:39:07, Hillf Danton wrote:
> > 
> > On March 30, 2017 7:55 PM Michal Hocko wrote:
> > > 
> > > @@ -5535,9 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
> > >  			zone_start_pfn, (zone_start_pfn + size));
> > > 
> > >  	zone_init_free_lists(zone);
> > > -	zone->initialized = 1;
> > > -
> > > -	return 0;
> > >  }
> > Nit: Add changes more than correct.
> 
> I am sorry, I do not follow?

OK, got it. init_currently_empty_zone should be changed to void. Screw
up during the split of the initial patch. Will fix that up. Also
zone_spans_range should go to patch 5 because it doesn't have any user
until then.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3DC6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:24:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 56so36982045wrx.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:24:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y57si416130wry.133.2017.06.14.02.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 02:24:42 -0700 (PDT)
Date: Wed, 14 Jun 2017 11:24:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of
 is_zone_device_section
Message-ID: <20170614092438.GM6045@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-5-mhocko@kernel.org>
 <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
 <20170614061259.GB14009@WeideMBP.lan>
 <20170614063206.GF6045@dhcp22.suse.cz>
 <20170614091206.GA15768@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614091206.GA15768@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Wed 14-06-17 17:12:06, Wei Yang wrote:
> On Wed, Jun 14, 2017 at 08:32:06AM +0200, Michal Hocko wrote:
> >On Wed 14-06-17 14:12:59, Wei Yang wrote:
> >[...]
> >> Hi, Michal
> >> 
> >> Not sure you missed this one or you think this is fine.
> >> 
> >> Hmm... this will not happen since we must offline a whole memory_block?
> >
> >yes
> >
> >> So the memory_hotplug/unplug unit is memory_block instead of mem_section?
> >
> >yes.
> 
> If this is true, the check_hotplug_memory_range() should be fixed too.

as I've said earlier. There are many code paths which are quite
confusing and they expect sub-section granularity while they in fact
won't work with sub memblock granularity. This is a larger project
I am afraid and it would be great if you are willing to try to
consolidate that code. I have that on my todo list but there are more
pressing things to address first for me now.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA6186B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 02:49:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so20883752wrc.8
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 23:49:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j67si6626309wmg.92.2017.06.11.23.49.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Jun 2017 23:49:57 -0700 (PDT)
Date: Mon, 12 Jun 2017 08:49:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of
 is_zone_device_section
Message-ID: <20170612064952.GE4145@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-5-mhocko@kernel.org>
 <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
 <CADZGycZtBzA7E_nsKSxYZ8HFGQ2cpQqN62G4MfU1E9vwC2UfcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADZGycZtBzA7E_nsKSxYZ8HFGQ2cpQqN62G4MfU1E9vwC2UfcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Sat 10-06-17 22:58:21, Wei Yang wrote:
> On Sat, Jun 10, 2017 at 5:56 PM, Wei Yang <richard.weiyang@gmail.com> wrote:
[...]
> > Hmm... one question about the memory_block behavior.
> >
> > In case one memory_block contains more than one memory section.
> > If one section is "device zone", the whole memory_block is not visible
> > in sysfs. Or until the whole memory_block is full, the sysfs is visible.
> >
> 
> Ok, I made a mistake here. The memory_block device is visible in this
> case, while the sysfs link between memory_block and node is not visible
> for the whole memory_block device.

yes the behavior is quite messy

> 
> BTW, current register_mem_sect_under_node() will create the sysfs
> link between memory_block and node for each pfn, while actually
> we only need one link between them. If I am correct.
> 
> If you think it is fine, I would like to change this one to create the link
> on section base.

My longer term plan was to unify all the code to be either memory block
or memory section oriented. The first sounds more logical from the user
visible granularity point of view but there might be some corner cases
which would require to use section based approach. I didn't have time to
study that. If you want to play with that, feel free of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A032B6B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 08:41:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 10so2288725wml.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 05:41:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23si2708713eda.31.2017.05.17.05.41.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 05:41:53 -0700 (PDT)
Date: Wed, 17 May 2017 14:41:46 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Message-ID: <20170517124145.GA18988@dhcp22.suse.cz>
References: <1494569882.21563.8.camel@gmail.com>
 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
 <1494973607.21847.50.camel@kernel.crashing.org>
 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
 <1495011826.3092.18.camel@kernel.crashing.org>
 <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
 <1495014995.3092.20.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495014995.3092.20.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed 17-05-17 19:56:35, Benjamin Herrenschmidt wrote:
> On Wed, 2017-05-17 at 10:15 +0100, Mel Gorman wrote:
[...]
> > Fine -- hot add the memory from the device via a userspace trigger and
> > have the userspace trigger then setup the policies to isolate CDM from
> > general usage.
> 
> This is racy though. The memory is hot added, but things can get
> allocated all over it before it has time to adjust the policies. Same
> issue we had with creating a CMA I believe.

memory hotplug is by definition 2 stage. Physical hotadd which just
prepares memory blocks and allocates struct pages and the memory online
phase. You can handle the policy part from the userspace before onlining
te first memblock from your CDM NUMA node.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

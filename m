Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECD7B6B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:39:31 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d144so5631291vka.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:39:31 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id l124si1184132vki.2.2017.05.17.12.39.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 12:39:30 -0700 (PDT)
Message-ID: <1495049952.3092.41.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 18 May 2017 05:39:12 +1000
In-Reply-To: <alpine.DEB.2.20.1705170853470.7925@east.gentwo.org>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
	 <1494973607.21847.50.camel@kernel.crashing.org>
	 <alpine.DEB.2.20.1705170853470.7925@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>

On Wed, 2017-05-17 at 08:54 -0500, Christoph Lameter wrote:
> You can provide a library that does it?
> 
> > The base idea behind the counters we have on the link is for the HW to
> > know when memory is accessed "remotely", so that the device driver can
> > make decision about migrating pages into or away from the device,
> > especially so that applications don't have to concern themselves with
> > memory placement.
> 
> Library can enquire about the current placement of the pages and move them
> if necessary?

No, doing that from a library would not work. It should be done by the
driver, but that's not a problem in the proposed scheme and doesn't
require new MM hooks afaik so I don't think there's a debate here.

>From my understanding, the main discussion revolves around isolation,
ie, whether to change the NUMA core to add nodes on which no allocation
will take place by default or not.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

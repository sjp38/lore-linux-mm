Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15F3C6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:57:18 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m28so3417767uab.9
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:57:18 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 18si1016530uat.212.2017.05.17.06.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 06:57:17 -0700 (PDT)
Date: Wed, 17 May 2017 08:54:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC summary] Enable Coherent Device Memory
In-Reply-To: <1494973607.21847.50.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.20.1705170853470.7925@east.gentwo.org>
References: <1494569882.21563.8.camel@gmail.com> <20170512102652.ltvzzwejkfat7sdq@techsingularity.net> <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com> <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
 <1494973607.21847.50.camel@kernel.crashing.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>

On Wed, 17 May 2017, Benjamin Herrenschmidt wrote:

> On Tue, 2017-05-16 at 09:43 +0100, Mel Gorman wrote:
> > I'm not sure what you're asking here. migration is only partially
> > transparent but a move_pages call will be necessary to force pages onto
> > CDM if binding policies are not used so the cost of migration will be
> > invisible. Even if you made it "transparent", the migration cost would
> > be incurred at fault time. If anything, using move_pages would be more
> > predictable as you control when the cost is incurred.
>
> One of the main point of this whole exercise is for applications to not
> have to bother with any of this and now you are bringing all back into
> their lap.

You can provide a library that does it?

> The base idea behind the counters we have on the link is for the HW to
> know when memory is accessed "remotely", so that the device driver can
> make decision about migrating pages into or away from the device,
> especially so that applications don't have to concern themselves with
> memory placement.

Library can enquire about the current placement of the pages and move them
if necessary?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

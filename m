Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 349F56B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:35:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t26so7459745qtg.12
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:35:52 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id t129si3047342qkf.278.2017.05.17.12.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 12:35:51 -0700 (PDT)
Message-ID: <1495049738.3092.36.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 18 May 2017 05:35:38 +1000
In-Reply-To: <20170517105812.plj54qwbr334w5r5@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
	 <1494973607.21847.50.camel@kernel.crashing.org>
	 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
	 <1495011826.3092.18.camel@kernel.crashing.org>
	 <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
	 <1495014995.3092.20.camel@kernel.crashing.org>
	 <20170517105812.plj54qwbr334w5r5@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 2017-05-17 at 11:58 +0100, Mel Gorman wrote:
> Remember that this will include the page table pages which may or may
> not be what you want.

It is fine. The GPU does translation using ATS, so the page tables are
effectively accessed by the nest MMU in the corresponding P9 chip, not
by the GPU itself. Thus we do want them to reside in system memory.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

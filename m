Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889A06B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:19:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so525556454pfg.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:19:35 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id m89si18975307pfk.254.2016.08.05.00.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 00:07:06 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
In-Reply-To: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
Date: Fri, 05 Aug 2016 17:07:01 +1000
Message-ID: <87mvkritii.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

> Fadump kernel reserves large chunks of memory even before the pages are
> initialized. This could mean memory that corresponds to several nodes might
> fall in memblock reserved regions.
>
...
> Register the memory reserved by fadump, so that the cache sizes are
> calculated based on the free memory (i.e Total memory - reserved
> memory).

The memory is reserved, with memblock_reserve(). Why is that not sufficient?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

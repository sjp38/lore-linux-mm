Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 628216B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 15:40:18 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id d1so66231669pas.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 12:40:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e185si10228274pfe.238.2016.08.03.12.40.17
        for <linux-mm@kvack.org>;
        Wed, 03 Aug 2016 12:40:17 -0700 (PDT)
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
 <20160803063538.GH6310@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57A248A1.40807@intel.com>
Date: Wed, 3 Aug 2016 12:40:17 -0700
MIME-Version: 1.0
In-Reply-To: <20160803063538.GH6310@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, mahesh@linux.vnet.ibm.com

On 08/02/2016 11:35 PM, Srikar Dronamraju wrote:
> On a regular kernel with CONFIG_FADUMP and fadump configured, 5% of the
> total memory is reserved for booting the kernel on crash.  On crash,
> fadump kernel reserves the 95% memory and boots into the 5% memory that
> was reserved for it. It then parses the reserved 95% memory to collect
> the dump.
> 
> The problem is not about the amount of memory thats reserved for fadump
> kernel. Even if we increase/decrease, we will still end up with the same
> issue.

Oh, and the dentry/inode caches are sized based on 100% of memory, not
the 5% that's left after the fadump reservation?

Is the deferred initialization kicked in progress at the time we do the
dentry/inode allocations?  Can waiting a bit let the allocation succeed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4186B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 05:43:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c78so6391716wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:43:41 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id cw8si3406628wjb.50.2016.10.12.02.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 02:43:40 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id c78so21069982wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:43:40 -0700 (PDT)
Date: Wed, 12 Oct 2016 11:43:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161012094337.GH17128@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FE0184.6030008@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
> Hi,
> 
> We have the following function policy_zonelist() which selects a zonelist
> during various allocation paths. With this, general user space allocations
> (IIUC might not have __GFP_THISNODE) fails while trying to get memory from
> a memory only node without CPUs as the application runs some where else
> and that node is not part of the nodemask.

I am not sure I understand. So you have a task with MPOL_BIND without a
cpu less node in the mask and you are wondering why the memory is not
allocated from that node?

> Why we insist on __GFP_THISNODE ?

AFAIU __GFP_THISNODE just overrides the given node to the policy
nodemask in case the current node is not part of that node mask. In
other words we are ignoring the given node and use what the policy says. 
I can see how this can be confusing especially when confronting the
documentation:

 * __GFP_THISNODE forces the allocation to be satisified from the requested
 *   node with no fallbacks or placement policy enforcements.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

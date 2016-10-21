Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 211C46B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:08:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so26582480lfe.4
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 05:08:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si3448802wmn.30.2016.10.21.05.08.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 05:08:23 -0700 (PDT)
Subject: Re: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in
 policy_zonelist
References: <20161013125958.32155-1-mhocko@kernel.org>
 <877f92ue91.fsf@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c8f66d33-f2e9-c29d-6cfd-9eebb4832ebe@suse.cz>
Date: Fri, 21 Oct 2016 14:08:19 +0200
MIME-Version: 1.0
In-Reply-To: <877f92ue91.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/21/2016 01:34 PM, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@kernel.org> writes:
>>
>
> For both MPOL_PREFERED and MPOL_INTERLEAVE we pick the zone list from
> the node other than the current running node. Why don't we do that for
> MPOL_BIND ?ie, if the current node is not part of the policy node mask
> why are we not picking the first node from the policy node mask for
> MPOL_BIND ?

For MPOL_PREFERED and MPOL_INTERLEAVE we got some explicit preference of nodes, 
so it makes sense that the nodes in the zonelist we pick are ordered by the 
distance from that node, regardless of current node.

For MPOL_BIND, we don't have preferences but restrictions. If the current cpu is 
from a node within the restriction, then great. If it's not, finding a node 
according to distance from current cpu is probably less arbitrary than by 
distance from the node that happens to have the lowest id in the node mask?

> -aneesh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

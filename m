Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1276B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:47:24 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so14933793wib.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:47:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eb1si915549wib.34.2015.03.02.05.47.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:47:22 -0800 (PST)
Message-ID: <54F469E9.7050303@suse.cz>
Date: Mon, 02 Mar 2015 14:47:21 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 2/3] mm, thp: really limit transparent hugepage allocation
 to local node
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271416580.7225@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502271416580.7225@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On 02/27/2015 11:17 PM, David Rientjes wrote:
> Commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
> node") restructured alloc_hugepage_vma() with the intent of only
> allocating transparent hugepages locally when there was not an effective
> interleave mempolicy.
>
> alloc_pages_exact_node() does not limit the allocation to the single
> node, however, but rather prefers it.  This is because __GFP_THISNODE is
> not set which would cause the node-local nodemask to be passed.  Without
> it, only a nodemask that prefers the local node is passed.
>
> Fix this by passing __GFP_THISNODE and falling back to small pages when
> the allocation fails.
>
> Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target
> node") suffers from a similar problem for khugepaged, which is also
> fixed.
>
> Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
> Fixes: 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target node")
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

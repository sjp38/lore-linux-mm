Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6696B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:09:44 -0400 (EDT)
Received: by igr7 with SMTP id 7so25163521igr.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:09:44 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id dd6si23142340pad.8.2015.07.24.13.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 13:09:43 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so18285865pdr.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:09:43 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:09:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 3/4] mm: use numa_mem_id in alloc_pages_node()
In-Reply-To: <1437749126-25867-3-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507241309290.5215@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> numa_mem_id() is able to handle allocation from CPU's on memory-less nodes,
> so it's a more robust fallback than the currently used numa_node_id().
> 
> Suggested-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

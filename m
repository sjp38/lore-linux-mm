Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7AC8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:32:32 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b24so2432926pls.11
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:32:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b12si18200289pls.32.2018.12.20.14.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Dec 2018 14:32:31 -0800 (PST)
Subject: Re: [RFC 0/7] Slab object migration for xarray V2
References: <01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@email.amazonses.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e7a2e0a5-d5b7-a158-52a1-6aa230501a94@infradead.org>
Date: Thu, 20 Dec 2018 14:32:14 -0800
MIME-Version: 1.0
In-Reply-To: <01000167cd1130c8-c9bebcb9-1f95-4f7c-b24a-90600d56c62f-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

On 12/20/18 11:21 AM, Christoph Lameter wrote:
> To test apply this patchset and run a workload that uses lots of radix tree objects
> 
> 
> Then go to
> 
> /sys/kernel/slab/radix_tree_node
> 
> Inspect the number of total objects that the slab can handle
> 
> 	cat total_objects

	cat objects # ???

(as below) (just checking :)


> 
> qmdr:/sys/kernel/slab/radix_tree_node# cat objects
> 868 N0=448 N1=168 N2=56 N3=196
> 
> And the number of slab pages used for those
> 
> 	cat slabs
> 
> qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
> 31 N0=16 N1=6 N2=2 N3=7
> 
> 
> Perform a cache shrink operation
> 
> 	echo 1 >shrink
> 
> 
> Now see how the slab has changed:
> 
> qmdr:/sys/kernel/slab/radix_tree_node# cat slabs
> 30 N0=15 N1=6 N2=2 N3=7
> qmdr:/sys/kernel/slab/radix_tree_node# cat objects
> 713 N0=349 N1=141 N2=52 N3=171


-- 
~Randy

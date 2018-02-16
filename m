Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F84A6B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 14:01:15 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f64so2753742plb.7
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:01:15 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n4si1735226pgp.369.2018.02.16.11.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 11:01:14 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
Date: Fri, 16 Feb 2018 11:01:12 -0800
MIME-Version: 1.0
In-Reply-To: <20180216160121.519788537@linux.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/16/2018 08:01 AM, Christoph Lameter wrote:
> In order to make this work just right one needs to be able to
> know the workload well enough to reserve the right amount
> of pages. This is comparable to other reservation schemes.

Yes, but it's a reservation scheme that doesn't show up in MemFree, for
instance.  Even hugetlbfs-reserved memory subtracts from that.

This has the potential to be really confusing to apps.  If this memory
is now not available to normal apps, they might plow into the invisible
memory limits and get into nasty reclaim scenarios.

Shouldn't this subtract the memory for MemFree and friends?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

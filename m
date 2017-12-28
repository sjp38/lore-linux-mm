Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA96E6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 00:19:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l20so8026306pgc.10
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 21:19:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q13si6439482pgc.706.2017.12.27.21.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Dec 2017 21:19:28 -0800 (PST)
Subject: Re: [RFC 0/8] Xarray object migration V1
References: <20171227220636.361857279@linux.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
Date: Wed, 27 Dec 2017 21:19:11 -0800
MIME-Version: 1.0
In-Reply-To: <20171227220636.361857279@linux.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On 12/27/2017 02:06 PM, Christoph Lameter wrote:
> This is a patchset on top of Matthew Wilcox Xarray code and implements
> object migration of xarray nodes. The migration is integrated into
> the defragmetation and shrinking logic of the slab allocator.
> 
> Defragmentation will ensure that all xarray slab pages have
> less objects available than specified by the slab defrag ratio.
> 
> Slab shrinking will create a slab cache with optimal object
> density. Only one slab page will have available objects per node.
> 
> To test apply this patchset on top of Matthew Wilcox Xarray code
> from Dec 11th (See infradead github).

linux-mm archive is missing patch 1/8 and so am I.

https://marc.info/?l=linux-mm



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

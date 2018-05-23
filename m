Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB0B6B0287
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:48:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c82-v6so2880702itg.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:48:49 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 5-v6si16737432ioy.96.2018.05.23.08.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 08:48:48 -0700 (PDT)
References: <152705221686.21414.771870778478134768.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152705223910.21414.17294372359464462569.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <40d702a1-1664-6556-ab64-e188f0733675@deltatee.com>
Date: Wed, 23 May 2018 09:48:42 -0600
MIME-Version: 1.0
In-Reply-To: <152705223910.21414.17294372359464462569.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v2 4/7] mm, devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE
 support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 22/05/18 11:10 PM, Dan Williams wrote:
> In preparation for consolidating all ZONE_DEVICE enabling via
> devm_memremap_pages(), teach it how to handle the constraints of
> MEMORY_DEVICE_PRIVATE ranges.
> 
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Reported-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

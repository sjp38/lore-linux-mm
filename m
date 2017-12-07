Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCCCB6B026F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:14:31 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g69so12571444ita.9
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:14:31 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id s6si3923013ioe.247.2017.12.07.11.14.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:14:30 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-9-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <a87e7e87-489d-c75a-f1b6-67ab22546a18@deltatee.com>
Date: Thu, 7 Dec 2017 12:14:22 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-9-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 08/14] mm: merge vmem_altmap_alloc into
 dev_pagemap_alloc_block_buf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> There is no clear separation between the two, so merge them.  Also move
> the device page map argument first for the more natural calling
> convention.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

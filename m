Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73CB16B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 13:34:21 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id k186so12746834ith.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 10:34:21 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l14si4182909itl.101.2017.12.07.10.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 10:34:20 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-2-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <ee51c0c0-b92a-e504-6d8f-fc6156a382c3@deltatee.com>
Date: Thu, 7 Dec 2017 11:34:15 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 01/14] mm: move get_dev_pagemap out of line
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> This is a pretty big function, which should be out of line in general,
> and a no-op stub if CONFIG_ZONE_DEVICD? is not set.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

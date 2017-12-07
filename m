Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFE466B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:35:48 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e41so13051204itd.5
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:35:48 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id v28si4490996ite.6.2017.12.07.11.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:35:48 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-13-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <724d551d-dd55-b353-59b0-5a0b3193a1f2@deltatee.com>
Date: Thu, 7 Dec 2017 12:35:46 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-13-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 12/14] memremap: remove find_dev_pagemap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> We already have the proper pfn value in both callers, so just open code
> the function there.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A86FB6B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:34:37 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id k186so13061486ith.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:34:37 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id p123si3883860iod.314.2017.12.07.11.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:34:36 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-12-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <672dce2f-49a7-a63c-34a1-54b04cb62c75@deltatee.com>
Date: Thu, 7 Dec 2017 12:34:34 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-12-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 11/14] memremap: simplify duplicate region handling in
 devm_memremap_pages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> __radix_tree_insert already checks for duplicates and returns -EEXIST in
> that case, so remove the duplicate (and racy) duplicates check.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

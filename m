Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2B36B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 13:49:26 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e41so12814353itd.5
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 10:49:26 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id z102si4308684ita.69.2017.12.07.10.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 10:49:25 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-4-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <4baf63fa-aaa9-0ecd-5cf7-ce0eb79ead8e@deltatee.com>
Date: Thu, 7 Dec 2017 11:49:20 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-4-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 03/14] mm: better abstract out dev_pagemap freeing
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> Add a new helper that both looks up the pagemap and updates the alloc
> counter.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

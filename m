Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D17EC6B0260
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 13:54:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so12531754itf.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 10:54:40 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n5si4319242itn.109.2017.12.07.10.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 10:54:40 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-6-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <cb99aadf-f173-6d52-7862-35f4d073ad42@deltatee.com>
Date: Thu, 7 Dec 2017 11:54:38 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-6-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 05/14] mm: better abstract out dev_pagemap offset
 calculation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> Add a helper that looks up the altmap (or later dev_pagemap) and returns
> the offset.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

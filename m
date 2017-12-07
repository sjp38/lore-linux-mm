Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76BF86B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:40:09 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y200so9019379itc.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:40:09 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id g2si3821101ioc.320.2017.12.07.11.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:40:08 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-14-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <3bad83fd-35b5-f920-35a5-3d3b4b41c701@deltatee.com>
Date: Thu, 7 Dec 2017 12:40:06 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-14-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 13/14] memremap: remove struct vmem_altmap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> There is no value in a separate vmem_altmap vs just embedding it into
> struct dev_pagemap, so merge the two.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 394B66B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 13:46:07 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id a3so12403992itg.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 10:46:07 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id j68si4409234itg.5.2017.12.07.10.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 10:46:06 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-3-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <50c8ed91-d8a1-8bfb-d4bc-b53896810d66@deltatee.com>
Date: Thu, 7 Dec 2017 11:46:02 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-3-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 02/14] mm: optimize dev_pagemap reference counting around
 get_dev_pagemap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> Change the calling convention so that get_dev_pagemap always consumes the
> previous reference instead of doing this using an explicit earlier call to
> put_dev_pagemap in the callers.
> 
> The callers will still need to put the final reference after finishing the
> loop over the pages.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>


Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

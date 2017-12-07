Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 173F86B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:09:02 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y200so8885278itc.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:09:02 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 135si4743719itp.126.2017.12.07.11.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 11:09:01 -0800 (PST)
References: <20171207150840.28409-1-hch@lst.de>
 <20171207150840.28409-8-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <199af200-beb9-04cc-2934-3dab4fa38748@deltatee.com>
Date: Thu, 7 Dec 2017 12:08:55 -0700
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-8-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 07/14] mm: split dev_pagemap memory map allocation from
 normal case
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org



On 07/12/17 08:08 AM, Christoph Hellwig wrote:
> No functional changes, just untangling the call chain.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

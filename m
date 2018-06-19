Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A11B86B000A
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 12:00:28 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n66-v6so8757898itg.0
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:00:28 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id p77-v6si16261iop.184.2018.06.19.09.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 09:00:25 -0700 (PDT)
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152938829462.17797.17960582127304725369.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <6d5ae5ea-48ed-fc0b-8945-a0478aa0ca5c@deltatee.com>
Date: Tue, 19 Jun 2018 10:00:19 -0600
MIME-Version: 1.0
In-Reply-To: <152938829462.17797.17960582127304725369.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v3 3/8] mm, devm_memremap_pages: Fix shutdown handling
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 19/06/18 12:04 AM, Dan Williams wrote:
> Cc: <stable@vger.kernel.org>
> Fixes: e8d513483300 ("memremap: change devm_memremap_pages interface...")
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Reported-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me.

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

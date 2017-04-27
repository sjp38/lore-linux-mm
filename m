Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 333746B02F4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:45:11 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g74so15623430ioi.4
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:45:11 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 201si11866651itw.49.2017.04.27.09.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 09:45:10 -0700 (PDT)
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
 <3e595ba6-2ea1-e25d-e254-6c7edcf23f88@deltatee.com>
 <CAPcyv4it4eGhLjws_j8+M1BeAzr_gHRZ4zE-nC+4QMpFp72Hyg@mail.gmail.com>
 <d2b0159c-9227-3283-2a57-74e03d47a0cd@deltatee.com>
 <CAPcyv4iFKb9VbwdjRwF4KLQ=2R6-=vYb6BbHQG6Kk-8QemC6WA@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <c9fdf838-049c-3e91-08df-c4c7a3806cfb@deltatee.com>
Date: Thu, 27 Apr 2017 10:45:06 -0600
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iFKb9VbwdjRwF4KLQ=2R6-=vYb6BbHQG6Kk-8QemC6WA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>



On 27/04/17 10:38 AM, Dan Williams wrote:
> ...is inside a for_each_device_pfn() loop.
> 

Ah, oops. Then that makes perfect sense. Thanks.

You may have my review tag if you'd like:

Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

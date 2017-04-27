Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7336B02F4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:33:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 67so9578648ite.6
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:33:42 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m64si3134773ioa.155.2017.04.27.09.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 09:33:41 -0700 (PDT)
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
 <3e595ba6-2ea1-e25d-e254-6c7edcf23f88@deltatee.com>
 <CAPcyv4it4eGhLjws_j8+M1BeAzr_gHRZ4zE-nC+4QMpFp72Hyg@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <d2b0159c-9227-3283-2a57-74e03d47a0cd@deltatee.com>
Date: Thu, 27 Apr 2017 10:33:37 -0600
MIME-Version: 1.0
In-Reply-To: <CAPcyv4it4eGhLjws_j8+M1BeAzr_gHRZ4zE-nC+4QMpFp72Hyg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>



On 27/04/17 10:14 AM, Dan Williams wrote:
> You're overlooking that the page reference count 1 after
> arch_add_memory(). So at the end of time we're just dropping the
> arch_add_memory() reference to release the page and related
> dev_pagemap.

Thanks, that does actually make a lot more sense to me now. However,
there still appears to be an asymmetry in that the pgmap->ref is
incremented once and decremented once per page...

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

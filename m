Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 014616B5A8B
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 17:19:18 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id r65so6809345iod.12
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:19:18 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id k189si278868ite.140.2018.11.30.14.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 14:19:17 -0800 (PST)
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275558526.76910.7535251937849268605.stgit@dwillia2-desk3.amr.corp.intel.com>
 <6875ca04-a36a-89ae-825b-f629ab011d47@deltatee.com>
 <CAPcyv4i9QXsX9Rjz9E3gi643LQbSzaO_+iFLqLS+QO-GmrS0Eg@mail.gmail.com>
 <14d6413c-b002-c152-5016-7ed659c08c24@deltatee.com>
 <CAPcyv4gZisOAE8VJPJChNXrWv0NhUevWuutsPdvNORBTOBXJfA@mail.gmail.com>
 <43778343-6d43-eb43-0de0-3db6828902d0@deltatee.com>
 <CAPcyv4hJV71RLhBCKgqc=nQ_D_upySD=ZZk0y=5Qk69kKPHFog@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <b8ae55a4-7c1a-cc35-beea-badf35a69b06@deltatee.com>
Date: Fri, 30 Nov 2018 15:19:03 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hJV71RLhBCKgqc=nQ_D_upySD=ZZk0y=5Qk69kKPHFog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v8 3/7] mm, devm_memremap_pages: Fix shutdown handling
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Bjorn Helgaas <bhelgaas@google.com>, Stephen Bates <sbates@raithlin.com>

Hey,

On 2018-11-29 11:51 a.m., Dan Williams wrote:
> Got it, let me see how bad moving arch_remove_memory() turns out,
> sounds like a decent approach to coordinate multiple users of a single
> ref.

I've put together a patch set[1] that fixes all the users of
devm_memremap_pages() without moving arch_remove_memory(). It's pretty
clean except for the p2pdma case which is fairly tricky but I don't
think there's an easy way around that.

If you come up with a better solution that's great, otherwise let me
know and I'll do some clean up and more testing and send this set to the
lists. Though, we might need to wait for your patch to land before we
can properly send the fix to it (the first patch in my series)...

Logan

[1] https://github.com/sbates130272/linux-p2pmem/ memremap_fix

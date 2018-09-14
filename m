Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABAC28E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:40:54 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y135-v6so10249094oie.11
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:40:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 39-v6sor3410325otx.69.2018.09.14.10.40.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Sep 2018 10:40:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180914131420.GC27141@lst.de>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680533172.453305.5701902165148172434.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180914131420.GC27141@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Sep 2018 10:40:52 -0700
Message-ID: <CAPcyv4gj1E75rZ7kUVfO--CDK_u=-Qci06qmu+cQhaH8V=szGA@mail.gmail.com>
Subject: Re: [PATCH v5 2/7] mm, devm_memremap_pages: Kill mapping "System RAM" support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 14, 2018 at 6:14 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Sep 12, 2018 at 07:22:11PM -0700, Dan Williams wrote:
>> Given the fact that devm_memremap_pages() requires a percpu_ref that is
>> torn down by devm_memremap_pages_release() the current support for
>> mapping RAM is broken.
>
> I agree.  Do you remember why we even added it in the first place?

It was initially a copy over from memremap() that catches these
attempts and returns a direct-map pointer.

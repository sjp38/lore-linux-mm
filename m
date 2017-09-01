Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEE36B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 21:01:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u206so2910524oif.5
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:01:04 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id d198si726715oib.307.2017.08.31.18.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 18:01:03 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id w10so10409546oie.1
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:01:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170831100359.GD21443@lst.de>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170831100359.GD21443@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Aug 2017 18:01:02 -0700
Message-ID: <CAPcyv4jvTB4Aiei1-fGybyJNopXQy9zADpnFcuRNdZCS4Mf1QQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: introduce MAP_VALIDATE, a mechanism for for
 safely defining new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Thu, Aug 31, 2017 at 3:03 AM, Christoph Hellwig <hch@lst.de> wrote:
>> +/*
>> + * The historical set of flags that all mmap implementations implicitly
>> + * support when file_operations.mmap_supported_mask is zero. With the
>> + * mmap3 syscall the deprecated MAP_DENYWRITE and MAP_EXECUTABLE bit
>> + * values are explicitly rejected with EOPNOTSUPP rather than being
>> + * silently accepted.
>> + */
>
> no mmap3 syscall here :)

True, that's stale.

> Do you also need to update the nommu mmap implementation?

Ugh, nommu defeats the MAP_SHARED_VALIDATE proposal from Linus.

        if ((flags & MAP_TYPE) != MAP_PRIVATE &&
            (flags & MAP_TYPE) != MAP_SHARED)
                return -EINVAL;

...parisc strikes again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

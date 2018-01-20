Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0AA46B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 19:15:54 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id r141so1949995oie.9
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 16:15:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u9sor4020538otd.106.2018.01.19.16.15.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 16:15:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180118000602.5527-2-jschoenh@amazon.de>
References: <20180118000602.5527-1-jschoenh@amazon.de> <20180118000602.5527-2-jschoenh@amazon.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 19 Jan 2018 16:15:53 -0800
Message-ID: <CAPcyv4gDpaJZeM0UULLdXU4YPXQUhDfZAzs8xyrXp89AbE-tSg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Fix devm_memremap_pages() collision handling
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jan_H=2E_Sch=C3=B6nherr?= <jschoenh@amazon.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jan 17, 2018 at 4:06 PM, Jan H. Sch=C3=B6nherr <jschoenh@amazon.de>=
 wrote:
> If devm_memremap_pages() detects a collision while adding entries
> to the radix-tree, we call pgmap_radix_release(). Unfortunately,
> the function removes *all* entries for the range -- including the
> entries that caused the collision in the first place.
>
> Modify pgmap_radix_release() to take an additional argument to
> indicate where to stop, so that only newly added entries are removed
> from the tree.
>
> Fixes: 9476df7d80df ("mm: introduce find_dev_pagemap()")
> Signed-off-by: Jan H. Sch=C3=B6nherr <jschoenh@amazon.de>

Looks good to me, applied for 4.16.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

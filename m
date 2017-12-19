Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C44D6B026B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:58:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r20so11335920wrg.23
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:58:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor763325wmd.41.2017.12.19.07.58.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:58:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1513685879-21823-2-git-send-email-wei.w.wang@intel.com>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com> <1513685879-21823-2-git-send-email-wei.w.wang@intel.com>
From: Philippe Ombredanne <pombredanne@nexb.com>
Date: Tue, 19 Dec 2017 16:58:10 +0100
Message-ID: <CAOFm3uHJF1X93iALES6njXrkpsk5bSsuXqcKQMWP4HGT0S8qeg@mail.gmail.com>
Subject: Re: [PATCH v20 1/7] xbitmap: Introduce xbitmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mawilcox@microsoft.com
Cc: virtio-dev@lists.oasis-open.org, LKML <linux-kernel@vger.kernel.org>, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@redhat.com, penguin-kernel@i-love.sakura.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, Paolo Bonzini <pbonzini@redhat.com>, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Matthew,

On Tue, Dec 19, 2017 at 1:17 PM, Wei Wang <wei.w.wang@intel.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> The eXtensible Bitmap is a sparse bitmap representation which is
> efficient for set bits which tend to cluster.  It supports up to
> 'unsigned long' worth of bits, and this commit adds the bare bones --
> xb_set_bit(), xb_clear_bit() and xb_test_bit().

<snip>

> --- /dev/null
> +++ b/include/linux/xbitmap.h
> @@ -0,0 +1,49 @@
> +/*
> + * eXtensible Bitmaps
> + * Copyright (c) 2017 Microsoft Corporation <mawilcox@microsoft.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of the
> + * License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * eXtensible Bitmaps provide an unlimited-size sparse bitmap facility.
> + * All bits are initially zero.
> + */

Would you mind using the new SPDX tags documented in Thomas patch set
[1] rather than this fine but longer legalese?

And if you could spread the word to others in your team this would be very nice.

Thank you!

[1] https://lkml.org/lkml/2017/12/4/934

-- 
Cordially
Philippe Ombredanne

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

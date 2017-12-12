Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E95D86B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 07:54:35 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a22so5997273wme.0
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 04:54:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor2766055wmc.12.2017.12.12.04.54.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 04:54:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1513079759-14169-2-git-send-email-wei.w.wang@intel.com>
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com> <1513079759-14169-2-git-send-email-wei.w.wang@intel.com>
From: Philippe Ombredanne <pombredanne@nexb.com>
Date: Tue, 12 Dec 2017 13:53:53 +0100
Message-ID: <CAOFm3uH29ZQSo92c_JXcffsonwh3PscdRe1p6vZCwinfauiYBw@mail.gmail.com>
Subject: Re: [PATCH v19 1/7] xbitmap: Introduce xbitmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, mawilcox@microsoft.com
Cc: virtio-dev@lists.oasis-open.org, LKML <linux-kernel@vger.kernel.org>, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, david@redhat.com, penguin-kernel@i-love.sakura.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, Paolo Bonzini <pbonzini@redhat.com>, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Matthew, Wei,

On Tue, Dec 12, 2017 at 12:55 PM, Wei Wang <wei.w.wang@intel.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> The eXtensible Bitmap is a sparse bitmap representation which is
> efficient for set bits which tend to cluster.  It supports up to
> 'unsigned long' worth of bits, and this commit adds the bare bones --
> xb_set_bit(), xb_clear_bit() and xb_test_bit().
>
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

[...]

> --- /dev/null
> +++ b/include/linux/xbitmap.h
> @@ -0,0 +1,52 @@
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

Have you considered using the new SPDX ids here instead? eg. this
would come out as a top line this way:

> +/* SPDX-License-Identifer: GPL-2.0+ */

Overall you get less boilerplate comment and more code, so this is a
win-win for everyone. This would nicely remove the legalese
boilerplate with the same effect, unless you are a legalese lover of
course. See Thomas doc patches for extra details.... and while you are
it if you could spread the words in your team and use it for all past,
present and future contributions, that would be much appreciated.

And as a side benefit to me, it will help me save on paper and ink
ribbons supplies for my dot matrix line printer each time I print the
source code of the whole kernel. ;)

Thanks for your consideration there.
-- 
Cordially
Philippe Ombredanne

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

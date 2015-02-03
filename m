Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 551426B0088
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:04:11 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so101926265pab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:04:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si4244618pdl.29.2015.02.03.15.04.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 15:04:10 -0800 (PST)
Date: Tue, 3 Feb 2015 15:04:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 02/19] Add kernel address sanitizer infrastructure.
Message-Id: <20150203150408.1913cf209c4552683cca8b35@linux-foundation.org>
In-Reply-To: <1422985392-28652-3-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-3-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On Tue, 03 Feb 2015 20:42:55 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

>
> ...
>
> Based on work by Andrey Konovalov <adech.fo@gmail.com>
>

We still don't have Andrey Konovalov's signoff?  As it stands we're
taking some of his work and putting it into Linux without his
permission.

> ...
>
> --- /dev/null
> +++ b/mm/kasan/kasan.c
> @@ -0,0 +1,302 @@
> +/*
> + * This file contains shadow memory manipulation code.
> + *
> + * Copyright (c) 2014 Samsung Electronics Co., Ltd.
> + * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
> + *
> + * Some of code borrowed from https://github.com/xairy/linux by
> + *        Andrey Konovalov <adech.fo@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + */

https://code.google.com/p/thread-sanitizer/ is BSD licensed and we're
changing it to GPL.

I don't do the lawyer stuff, but this is all a bit worrisome.  I'd be a
lot more comfortable with that signed-off-by, please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

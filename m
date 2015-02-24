Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 95DE06B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:12:30 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so1044708iga.0
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:12:30 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id v5si10080774igb.35.2015.02.24.14.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 14:12:28 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so36111124iec.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:12:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150224220843.GL19014@t510.redhat.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
	<CA+55aFz4D9fS1xt7fg0R9Bnngg+_TbNs3fSAaFwoV7eTeLfP5Q@mail.gmail.com>
	<20150224220843.GL19014@t510.redhat.com>
Date: Tue, 24 Feb 2015 14:12:28 -0800
Message-ID: <CA+55aFwa5YeW6T+Fo=CFs4RrtNAAy_snWxvG2CjS7KSwj07VOw@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, loberman@redhat.com, Larry Woodman <lwoodman@redhat.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

On Tue, Feb 24, 2015 at 2:08 PM, Rafael Aquini <aquini@redhat.com> wrote:
>
> Would you consider bringing it back, but instead of node memory state,
> utilizing global memory state instead?

Maybe. At least it would be saner than picking random values that make
absolutely no sense.

> People filing bugs complaining their applications that memory map files
> are getting hurt by it.

Show them. And as mentioned, last time this came up (and it has come
up before), it wasn't actually a real load, but some benchmark that
just did the prefetch, and then people were upset because their
benchmark numbers changed.

Which quite frankly doesn't make me care. The benchmark could equally
well just be changed to do prefetching in saner chunks instead.

So I really want to see real numbers from real loads, not some
nebulous "people noticed and complain" that doesn't even specify what
they did.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

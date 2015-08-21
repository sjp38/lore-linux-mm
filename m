Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id BF4EF6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 14:17:44 -0400 (EDT)
Received: by iodt126 with SMTP id t126so90800386iod.2
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 11:17:44 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id z10si1976618igl.22.2015.08.21.11.17.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 11:17:44 -0700 (PDT)
Received: by iodt126 with SMTP id t126so90800052iod.2
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 11:17:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440177121-12741-1-git-send-email-klamm@yandex-team.ru>
References: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
	<1440177121-12741-1-git-send-email-klamm@yandex-team.ru>
Date: Fri, 21 Aug 2015 11:17:43 -0700
Message-ID: <CA+55aFyc8bb=ASmQbhk72cFOOmGpNhowdWGtSn+biog69_f+LA@mail.gmail.com>
Subject: Re: [PATCH] mm: use only per-device readahead limit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Aug 21, 2015 at 10:12 AM, Roman Gushchin <klamm@yandex-team.ru> wrote:
>
> There are devices, which require custom readahead limit.
> For instance, for RAIDs it's calculated as number of devices
> multiplied by chunk size times 2.

So afaik, the default read-ahead size is 128kB, which is actually
smaller than the old 512-page limit.

Which means that you probably changed "ra_pages" somehow. Is it some
system tool that does that automatically, and if so based on what,
exactly?

I'm also slightly worried about the fact that now the max read-ahead
may actually be zero, and/or basically infinite (there's a ioctl to
set it that only tests that it's not negative). Does everything react
ok to that?

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

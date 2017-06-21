Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4F76B0433
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:23:54 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 84so92512iop.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:23:54 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id r22si13109761itr.51.2017.06.21.11.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 11:23:53 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id m62so37702909itc.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:23:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Jun 2017 11:23:52 -0700
Message-ID: <CA+55aFy14-DjPqiNhYBug_kK7zWAfvkRS9E5v5vuCgO+OBAJrg@mail.gmail.com>
Subject: Re: [PATCH v3 00/11] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22 PM, Andy Lutomirski <luto@kernel.org> wrote:
> There are three performance benefits here:

Side note: can you post the actual performance numbers, even if only
from some silly test program on just one platform? Things like lmbench
pipe benchmark or something?

Or maybe you did, and I just missed it. But when talking about
performance, I'd really like to always see some actual numbers.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C70986B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:37:33 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r22so3430076iod.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:37:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r185sor1184685itr.53.2017.11.29.09.37.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 09:37:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129105151.GA10179@arm.com>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
 <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
 <f09cd880-f647-7dc8-2ca9-67dab411c6c3@codeaurora.org> <20171129105151.GA10179@arm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 29 Nov 2017 09:37:31 -0800
Message-ID: <CA+55aFz_u+ry_TGEpUsD3GiA_T-kfKKa6GZT3sSjjwyBBR62xA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huang Ying <ying.huang@intel.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 29, 2017 at 2:51 AM, Will Deacon <will.deacon@arm.com> wrote:
>
> Linus -- if you want the latest architecture document, it's now available
> here without a click-through:

Thanks. I was sure there was something newer available than the ARMv8
pdf I had, but my google-fu failed miserably.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5BA6B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 13:27:20 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f84so170817457ioj.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 10:27:20 -0800 (PST)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id b4si9155879iog.198.2017.03.06.10.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 10:27:19 -0800 (PST)
Received: by mail-it0-x230.google.com with SMTP id m27so56003232iti.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 10:27:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 6 Mar 2017 10:27:18 -0800
Message-ID: <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
Subject: Re: [PATCHv4 00/33] 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 6, 2017 at 5:53 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Here is v4 of 5-level paging patchset. Please review and consider applying.

I think we should just aim for this being in 4.12. I don't see any
real reason to delay merging it, the main question in my mind is which
tree it would go through. A separate x86 -tip branch, or Andrew's mm
tree or me just pulling directly, or what?

I basically think it's in good enough shape that future work might as
well be based on this being merged. No?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

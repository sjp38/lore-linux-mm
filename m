Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1976B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 19:24:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l128so449214iol.12
        for <linux-mm@kvack.org>; Thu, 25 May 2017 16:24:26 -0700 (PDT)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id 201si85736iti.53.2017.05.25.16.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 16:24:25 -0700 (PDT)
Received: by mail-it0-x22f.google.com with SMTP id o5so65241833ith.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 16:24:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 May 2017 16:24:24 -0700
Message-ID: <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 25, 2017 at 1:33 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Here' my first attempt to bring boot-time between 4- and 5-level paging.
> It looks not too terrible to me. I've expected it to be worse.

If I read this right, you just made it a global on/off thing.

May I suggest possibly a different model entirely? Can you make it a
per-mm flag instead?

And then we

 (a) make all kthreads use the 4-level page tables

 (b) which means that all the init code uses the 4-level page tables

 (c) which means that all those checks for "start_secondary" etc can
just go away, because those all run with 4-level page tables.

Or is it just much too expensive to switch between 4-level and 5-level
paging at run-time?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26F9B6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 07:54:23 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a63so154319wrc.1
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:54:23 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id b9si764838wmh.93.2017.11.28.04.54.21
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 04:54:22 -0800 (PST)
Date: Tue, 28 Nov 2017 13:54:10 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 2/5] x86/mm/kaiser: Add a banner
Message-ID: <20171128125410.36t4uoh7a3pbk3hx@pd.tnic>
References: <20171127223110.479550152@infradead.org>
 <20171127223405.231444600@infradead.org>
 <CALCETrV-vk-49HkOXi6EW0zxzDrCj2DM4N2i33AuX-vGNb0SHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrV-vk-49HkOXi6EW0zxzDrCj2DM4N2i33AuX-vGNb0SHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 07:36:40PM -0800, Andy Lutomirski wrote:
> ** The word "shadow" needs to die, too.  I know what shadow page
> tables are, and they have *nothing* to do with KAISER.

ACK to that. Calling them "shadow" is mishandling an already overloaded
term.

Let's call them the user page tables as we call the other the kernel
page tables already. Nicely balanced.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

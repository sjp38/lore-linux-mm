Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 627D16B028D
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 11:38:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so1715715wrd.17
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 08:38:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor1624575edk.55.2017.10.14.08.37.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 08:38:00 -0700 (PDT)
Date: Sat, 14 Oct 2017 18:37:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2, RFC] x86/boot/compressed/64: Handle 5-level paging
 boot if kernel is above 4G
Message-ID: <20171014153757.wpyzw76cswgw4lym@node.shutemov.name>
References: <20171013122345.86304-1-kirill.shutemov@linux.intel.com>
 <20171014073353.trbh3w4lo7t2njsi@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171014073353.trbh3w4lo7t2njsi@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Oct 14, 2017 at 09:33:53AM +0200, Ingo Molnar wrote:
> Yeah, so first most of this code should be moved from assembly to C. Any reason 
> why that cannot be done?

Well, we can move a little bit more code into C, like populating the
trampoline page, but I don't the think we can move the rest.

Switching to compatibility mode is too low-level to be written in C.

And we cannot write the trampoline code in C, as it's in 32-bit mode and
we wouldn't be able to generate it from C in a sane manner while building
64-bit kernel (we discussed this before).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

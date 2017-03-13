Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE7D26B038C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:46:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e136so54754558itc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:46:27 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id n76si8295846itn.46.2017.03.13.12.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 12:46:27 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id g138so38672711itb.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:46:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 13 Mar 2017 12:46:26 -0700
Message-ID: <CA+55aFzo95ZYAW-M1uPp0Q0CJUVbc-FTCZuJQ-TtjL6S+E7hKg@mail.gmail.com>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 13, 2017 at 7:33 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Here's the first bunch of patches of 5-level patchset. Let's see if I'm on
> right track addressing Ingo's feedback. :)

Considering the bug we just had with the HAVE_GENERIC_RCU_GUP code,
I'm wondering if people would be willing to look at what it would take
to make x86 use the generic version?

The x86 version of __get_user_pages_fast() seems to be quite similar
to the generic one. And it would be lovely if all the main
architectures shared the same core gup code.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

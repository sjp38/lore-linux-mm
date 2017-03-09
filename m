Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 536896B0468
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 15:26:12 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id z13so46685898iof.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 12:26:12 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id u125si23760itg.1.2017.03.09.12.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 12:26:11 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id z13so36290725iof.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 12:26:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170309142408.2868-1-kirill.shutemov@linux.intel.com>
References: <20170309142408.2868-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 9 Mar 2017 12:26:10 -0800
Message-ID: <CA+55aFzwYvtSA-E+eKjPb3AdmziLeZ5y0vfMjVUoJVC=JrmnBg@mail.gmail.com>
Subject: Re: [PATCHv2 0/7] 5-level paging: prepare generic code
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Mar 9, 2017 at 6:24 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Here's relatively low-risk part of 5-level paging patchset.
> Merging it now would make x86 5-level paging enabling in v4.12 easier.
>
> Linus, please consider applying.

Ok, I've applied this to a local branch in my tree for now, I'll wait
some more in case somebody wants to ack/nak before I merge that
branch.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

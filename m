Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A298D6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 14:35:11 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g138so73964072itb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:35:11 -0800 (PST)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id 130si11829788itj.52.2017.03.06.11.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 11:35:10 -0800 (PST)
Received: by mail-it0-x235.google.com with SMTP id h10so56300868ith.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:35:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170306190911.GB27719@node.shutemov.name>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
 <alpine.DEB.2.20.1703061935220.3771@nanos> <CA+55aFyL7UDP4AyscTOO=pxYuFG2GkG_rbEPgqBMBwkEi7t3vw@mail.gmail.com>
 <20170306190911.GB27719@node.shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 6 Mar 2017 11:35:09 -0800
Message-ID: <CA+55aFyykmVyUmT+oQ-1-uUrLGht7qrAAWHxP7aFPgsoeV1uhA@mail.gmail.com>
Subject: Re: [PATCHv4 00/33] 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 6, 2017 at 11:09 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> The first 7 patches are relatively low-risk. It would be nice to have them
> in earlier.

Ok, I gave those another look since you mentioned them in particular,
and they still look fine and non-controversial to me. I'd be willing
to take them directly, and into 4.11, to make future integration
eastier and avoid conflicts with other mm code during the 4.12 merge
window.

Just looking at my own inbox, I would suggest that maybe you should
send that small early series as a separate patch series, because those
patches actually got mixed up in my inbox with all the other patches
in the series. Email sending in quick succession does not tend to keep
things ordered. I suspect that happened to others too.

We might have people who are *not* willing to look at the whole
33-patch series that has a lot of x86 code in it, but are willing to
look through the first 7 emails when they are clearly separated out..

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C66B6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:31:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k1so1940796pgq.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:31:41 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 32si1246745ple.466.2017.12.13.10.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 10:31:40 -0800 (PST)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DC128218EB
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:31:39 +0000 (UTC)
Received: by mail-it0-f46.google.com with SMTP id u62so5259777ita.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:31:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name> <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com> <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
 <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 13 Dec 2017 10:31:17 -0800
Message-ID: <CALCETrUX0Bx+s8iV-njDn8=riOzp5L1AqKU_MN-VPvZLLs8y_Q@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed, Dec 13, 2017 at 10:08 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>
>> Which is why get_user_pages() _should_ enforce this.
>>
>> What use are protection keys if you can trivially circumvent them?
>
> No, we will *not* worry about protection keys in get_user_pages().
>

Hmm.  If I goof some pointer and pass that bogus pointer to read(2),
and I'm using pkey to protect my mmapped database, I think i'd rather
that read(2) fail.  Sure, pkey is trivially circumventable using
wrpkru or mprotect, but those are obvious dangerous functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

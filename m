Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEFF6B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:21:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j7so1898405pgv.20
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:21:10 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s4si1603529pgp.418.2017.12.13.10.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 10:21:08 -0800 (PST)
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
 <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com>
 <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
 <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b40719da-a23b-72a4-ddde-54c2f5d96820@intel.com>
Date: Wed, 13 Dec 2017 10:21:06 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On 12/13/2017 10:08 AM, Linus Torvalds wrote:
> On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstr <peterz@infradead.org> wrote:
>> Which is why get_user_pages() _should_ enforce this.
>> 
>> What use are protection keys if you can trivially circumvent them?
> No, we will *not* worry about protection keys in get_user_pages().

We did introduce some support for it here:

> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=33a709b25a760b91184bb335cf7d7c32b8123013

> They are not "security". They are a debug aid and safety against
> random mis-use.

Totally agree.  It's not about security.  As I mentioned in the commit,
the goal here was to try to make pkey-protected access behavior
consistent with mprotect().

I still think this was nice to do and probably surprises users less than
if we didn't have it.

> We already allow access to PROT_NONE for gdb and friends, very much on purpose.

Yup, exactly, and that's one of the reasons that I tried to call those
out as "remote" access that are specicifially no subject to protection keys.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

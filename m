Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7D46B0276
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:30:04 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id h185so86541vkg.20
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:30:04 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 35si2808805edk.490.2018.01.17.01.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:33:32 -0800 (PST)
Date: Wed, 17 Jan 2018 10:33:31 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180117093331.GL28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <CALCETrWfetqrcUavH79akLgsMMWjE6JiW9c3OztYTk6Zv_RT1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWfetqrcUavH79akLgsMMWjE6JiW9c3OztYTk6Zv_RT1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

Hi Andy,

thanks a lot for your review and input, especially on the entry-code
changes!

On Tue, Jan 16, 2018 at 02:26:22PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > The code has not run on bare-metal yet, I'll test that in
> > the next days once I setup a 32 bit box again. I also havn't
> > tested Wine and DosEMU yet, so this might also be broken.
> >
> 
> If you pass all the x86 selftests, then Wine and DOSEMU are pretty
> likely to work :)

Okay, good to know. I will definitily run them and make them pass :)


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

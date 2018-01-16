Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2F356B0280
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:02:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so9839849pge.13
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:02:30 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p13si2325603plo.628.2018.01.16.11.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:02:29 -0800 (PST)
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <90748aea-6fc0-48a5-d154-c98465fea42c@intel.com>
Date: Tue, 16 Jan 2018 11:02:28 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On 01/16/2018 10:59 AM, Linus Torvalds wrote:
>> The code has not run on bare-metal yet, I'll test that in
>> the next days once I setup a 32 bit box again. I also havn't
>> tested Wine and DosEMU yet, so this might also be broken.
> .. and please run all the segment and syscall selfchecks that Andy has written.
> 
> But yes, checking bare metal, and checking the "odd" applications like
> Wine and dosemu (and kvm etc) within the PTI kernel is certainly a
> good idea.

I tried to document a list of the "gotchas" that tripped us up during
the 64-bit effort under "Testing":

> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=x86/pti&id=01c9b17bf673b05bb401b76ec763e9730ccf1376

NMIs were a biggie too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

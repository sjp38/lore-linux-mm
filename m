Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6446B0278
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 16:28:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g187so4422412wmg.2
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 13:28:41 -0800 (PST)
Received: from ppsw-30.csi.cam.ac.uk (ppsw-30.csi.cam.ac.uk. [131.111.8.130])
        by mx.google.com with ESMTPS id x26si2003039wmc.182.2018.02.09.13.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 13:28:39 -0800 (PST)
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209210918.GA7333@amd>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Message-ID: <a5e37af1-cfa3-1284-cb1c-3912c30505e3@citrix.com>
Date: Fri, 9 Feb 2018 21:28:08 +0000
MIME-Version: 1.0
In-Reply-To: <20180209210918.GA7333@amd>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On 09/02/2018 21:09, Pavel Machek wrote:
> On Fri 2018-02-09 17:47:43, Andy Lutomirski wrote:
>> PCID bit set in CPUID should print a big fat warning like "WARNING:
>> you are using 32-bit PTI on a 64-bit PCID-capable CPU.  Your
>> performance will increase dramatically if you switch to a 64-bit
>> kernel."
> Hardware supports PCID even on 32-bit kernels, no?

Attempting to set CR4.PCIDE is disallowed outside of long mode.  It is
strictly a 64bit-only feature.

~Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

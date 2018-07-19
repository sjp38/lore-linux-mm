Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 823026B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 19:21:44 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so4402003wrr.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 16:21:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t9-v6si299933wrq.111.2018.07.19.16.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 16:21:43 -0700 (PDT)
Date: Fri, 20 Jul 2018 01:21:33 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/39 v8] PTI support for x86-32
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.21.1807200114130.1693@nanos.tec.linutronix.de>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

Joerg,

On Wed, 18 Jul 2018, Joerg Roedel wrote:
> 
> here is version 8 of my patches to enable PTI on x86-32. The
> last version got some good review which I mostly worked into
> this version.

I went over the whole set once again and did not find any real issues. As
the outstanding review comments are addressed, I decided that only broader
exposure can shake out eventually remaining issues. Applied and pushed out,
so it should show up in linux-next soon.

The mm regression seems to be sorted, so there is no immeditate fallout
expected.

Thanks for your patience in reworking this over and over. Thanks to Andy
for putting his entry focssed eyes on it more than once. Great work!

Thanks,

	tglx

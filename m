Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 651D16B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:00:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h1-v6so4455545wre.0
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:00:49 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.190])
        by mx.google.com with ESMTPS id 4si3193714edy.309.2018.04.19.02.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 02:00:47 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 03/35] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Date: Thu, 19 Apr 2018 09:01:12 +0000
Message-ID: <15c09c5a13d244ba8ad3f69ee0a24657@AcuMS.aculab.com>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <1523892323-14741-4-git-send-email-joro@8bytes.org>
 <87k1t4t7tw.fsf@linux.intel.com>
 <CA+55aFxKzsPQW4S4esvJY=wb7D3LKBdDDcXoMKJSqcOgnD3FuA@mail.gmail.com>
 <20180419003833.GO6694@tassilo.jf.intel.com>
In-Reply-To: <20180419003833.GO6694@tassilo.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andi Kleen' <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the
 arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy
 Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh
 Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter
 Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Waim@linux.intel.com" <Waim@linux.intel.com>

From: Andi Kleen
> Sent: 19 April 2018 01:39
>=20
> On Wed, Apr 18, 2018 at 05:02:02PM -0700, Linus Torvalds wrote:
> > On Wed, Apr 18, 2018 at 4:26 PM, Andi Kleen <ak@linux.intel.com> wrote:
> > >
> > > Seems like a hack. Why can't that be stored in a per cpu variable?
> >
> > It *is* a percpu variable - the whole x86_tss structure is percpu.
> >
> > I guess it could be a different (separate) percpu variable, but might
> > as well use the space we already have allocated.
>=20
> Would be better/cleaner to use a separate variable instead of reusing
> x86 structures like this. Who knows what subtle side effects that
> may have eventually.
>=20
> It will be also easier to understand in the code.

You could (probably) use an unnamed union in the x86_tss structure
so that it is more obvious that the two variables share a location.

	David

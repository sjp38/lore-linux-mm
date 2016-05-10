Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F95A6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 08:04:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so12401977wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 05:04:39 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id iq6si2250636wjb.116.2016.05.10.05.04.37
        for <linux-mm@kvack.org>;
        Tue, 10 May 2016 05:04:38 -0700 (PDT)
Date: Tue, 10 May 2016 14:04:34 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Message-ID: <20160510120434.GC16752@pd.tnic>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <CALCETrUdrMAmE6Vgj6_PALdmRZVVKa3QDwJtO=YDTOQdox=rhQ@mail.gmail.com>
 <57211CAB.9040902@amd.com>
 <CALCETrWAP5hxQeVSwNx-XkO53-X3bX0LasjOuHxeRWCTob7JAA@mail.gmail.com>
 <5730A91E.6040601@redhat.com>
 <5730FC33.2060804@amd.com>
 <5731C4B7.9000209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5731C4B7.9000209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 10, 2016 at 01:23:35PM +0200, Paolo Bonzini wrote:
> It can send plaintext packets that will be stored encrypted in memory.
> (Of course the hypervisor can do that too if it has access to the guest
> network).

And then what?

You need to find out where exactly (which pages) got the packets. If at
all. I don't think you can do that from another VM, you probably are
more lucky if you're the hypervisor. But I'm no security guy so I'm
genuinely asking...

In any case, it sounds hard to do.

> And that's great!  However, it is very different from "virtual machines
> need not fully trust the hypervisor and administrator of their host
> system" as said in the whitepaper.

You know, those documents can be corrected ... :)

> SEV protects pretty well from sibling VMs, but by design
> this generation of SEV leaks a lot of information to an evil
> host---probably more than enough to mount a ROP attack or to do evil
> stuff that Andy outlined.
>
> My problem is that people will read AMD's whitepaper, not your message
> on LKML, and may put more trust in SEV than (for now) they should.

So if people rely on only one security feature, then they get what they
deserve. And even non-security people like me know that proper security
is layering of multiple features/mechanisms which should take care of
aspects only, not of everything. And not a single magic wand which makes
sh*t secure. :)

So let's please get real: the feature is pretty elegant IMO and gives
you a lot more security than before.

Can it be made better/cover more aspects?

Absolutely and it is a safe bet that it will be. You don't just
implement stuff like that in hw to not improve on it in future
iterations. It is like with all hardware features, they get improved
with time and CPU revisions.

Now, can people please look at the actual code and complain about stuff
that bothers them codewise? We've tried to make it as unobtrusive as
possible to the rest of the kernel but improvement suggestions are
always welcome!

:-)

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

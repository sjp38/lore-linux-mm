Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 708B96B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 17:31:14 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 3so3413578pfo.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:31:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si1936429plb.805.2017.11.29.14.31.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 14:31:13 -0800 (PST)
Date: Wed, 29 Nov 2017 23:31:04 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171129223103.in4qmtxbj2sawhpw@pd.tnic>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
 <793b9c55-e85b-97b5-c857-dd8edcda4081@zytor.com>
 <20171129191902.2iamm3m23e3gwnj4@pd.tnic>
 <e4463396-9b7c-2fe8-534c-73820c0bce5f@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e4463396-9b7c-2fe8-534c-73820c0bce5f@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 29, 2017 at 01:33:28PM -0800, H. Peter Anvin wrote:
> You can't dump a message about *anything* if the bootloader bypasses the
> checks that happen before we leave the firmware behind.  This is what
> this is about.  For BIOS or EFI boot that go through the proper stub
> functions we will print a message just fine, as we already validate the
> "required features" structure (although please do verify that the
> relevant words are indeed being checked.)

A couple of points:

* so this box here has a normal grub installation and apparently grub
jumps to some other entry point.

* I'm not convinced we need to do everything you typed because this is
only a temporary issue and once X86_5LEVEL is complete, it should work.
I mean, it needs to work otherwise forget single-system image and I
don't think we want to give that up.

> However, if the bootloader jumps straight into the code what do you
> expect it to do?  We have no real concept about what we'd need to do to
> issue a message as we really don't know what devices are available on
> the system, etc.  If the screen_info field in struct boot_params has
> been initialized then we actually *do* know how to write to the screen
> -- if you are okay with including a text font etc. since modern systems
> boot in graphics mode.

We switch to text mode and dump our message. Can we do that?

I wouldn't want to do any of this back'n'forth between kernel and boot
loader because that sounds fragile, at least to me. And again, I'm
not convinced we should spend too much energy on this as the issue is
temporary AFAICT.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

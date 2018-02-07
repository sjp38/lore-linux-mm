Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A600D6B0369
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 15:50:26 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w125so2941610itf.0
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 12:50:26 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id t12si2267480ite.123.2018.02.07.12.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 12:50:25 -0800 (PST)
Subject: Re: [RFC 0/3] x86: Patchable constants
From: "H. Peter Anvin" <hpa@zytor.com>
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
 <CA+55aFxJO7kDNp6wRnU58Z6-sPbK1SqdzpgLBTAe54mdPjnd=g@mail.gmail.com>
 <8fea57cc-8772-f8b4-3298-91b0de126358@zytor.com>
Message-ID: <83ddad10-936f-9848-e3d1-8c6e73ab2969@zytor.com>
Date: Wed, 7 Feb 2018 12:43:33 -0800
MIME-Version: 1.0
In-Reply-To: <8fea57cc-8772-f8b4-3298-91b0de126358@zytor.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

FYI: the interface I'm implementing looks like this:

	[output =] const_op(data, variable);

... where variable can be any variable with a static address, although
in any sane scenario it should be __ro_after_init.  During
initialization, it kicks out to an out-of-line (.alternatives_aux)
handler which accesses the variable in normal fashion, but at
alternatives-patching time it inlines the relevant opcodes.

Some of the assembly infrastructure for this is indeed hairy, especially
when the out-of-line hander needs temp registers.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

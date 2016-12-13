Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA7F6B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:44:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so3996225pgd.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:44:44 -0800 (PST)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id m136si49593420pga.237.2016.12.13.14.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 14:44:43 -0800 (PST)
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com>
 <20161208202013.uutsny6avn5gimwq@pd.tnic>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com>
Date: Tue, 13 Dec 2016 14:44:06 -0800
MIME-Version: 1.0
In-Reply-To: <20161208202013.uutsny6avn5gimwq@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 12/08/16 12:20, Borislav Petkov wrote:
> On Thu, Dec 08, 2016 at 12:08:53PM -0800, Linus Torvalds wrote:
>> Especially since that's some of the ugliest inline asm ever due to the
>> nasty BX handling.
> 
> Yeah, about that: why doesn't gcc handle that for us like it would
> handle a clobbered register? I mean, it *should* know that BX is live
> when building with -fPIC... The .ifnc thing looks really silly.
> 

When compiling with -fPIC gcc treats ebx as a "fixed register".  A fixed
register can't be spilled, and so a clobber of a fixed register is a
fatal error.

Like it or not, it's how it works.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

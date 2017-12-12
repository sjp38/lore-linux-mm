Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D78F6B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 15:21:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y2so84208pgv.8
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:21:11 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x1si13352412pfj.295.2017.12.12.12.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 12:21:09 -0800 (PST)
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
References: <20171212173221.496222173@linutronix.de>
 <20171212173334.345422294@linutronix.de>
 <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
 <alpine.DEB.2.20.1712122017100.2289@nanos>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
Date: Tue, 12 Dec 2017 12:21:07 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712122017100.2289@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On 12/12/2017 11:21 AM, Thomas Gleixner wrote:
> The only critical interaction is the return to user path (user CS/SS) and
> we made sure with the LAR touching that these are precached in the CPU
> before we go into fragile exit code.

How do we make sure that it _stays_ cached?

Surely there is weird stuff like WBINVD or SMI's that can come at very
inconvenient times and wipe it out of the cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

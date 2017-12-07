Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB6446B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 03:24:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w141so3028952wme.1
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 00:24:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e201sor1430327wmd.76.2017.12.07.00.24.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 00:24:52 -0800 (PST)
Date: Thu, 7 Dec 2017 09:24:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 3/4] x86/boot/compressed/64: Introduce
 place_trampoline()
Message-ID: <20171207082449.a64fr5pmasunygmf@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-4-kirill.shutemov@linux.intel.com>
 <20171207063048.w46rrq2euzhtym3j@gmail.com>
 <20171207081659.GC2739@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207081659.GC2739@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Matthew Wilcox <willy@infradead.org> wrote:

> On Thu, Dec 07, 2017 at 07:30:48AM +0100, Ingo Molnar wrote:
> > > But if the bootloader put the kernel above 4G (not sure if anybody does
> > > this), we would loose control as soon as paging is disabled as code
> > > becomes unreachable.
> > 
> > Yeah, so instead of the double 'as' which is syntactically right but a bit 
> > confusing to read, how about something like:
> > 
> >   But if the bootloader put the kernel above 4G (not sure if anybody does
> >   this), we would loose control as soon as paging is disabled, because the
> >   code becomes unreachable to the CPU.
> 
> btw, it's "lose control".

Indeed!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

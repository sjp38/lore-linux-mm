Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD616B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:28:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 55so5788860wrx.21
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:28:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m75sor227720wmi.50.2017.12.08.03.28.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 03:28:46 -0800 (PST)
Date: Fri, 8 Dec 2017 12:28:42 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 3/4] x86/boot/compressed/64: Introduce
 place_trampoline()
Message-ID: <20171208112842.jfh4rnu3nzdab4o6@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-4-kirill.shutemov@linux.intel.com>
 <20171207063048.w46rrq2euzhtym3j@gmail.com>
 <20171208110722.gl2cxdq2vlg6olih@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208110722.gl2cxdq2vlg6olih@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Dec 07, 2017 at 07:30:48AM +0100, Ingo Molnar wrote:
> > > We also need a small stack in the trampoline to re-enable long mode via
> > > long return. But stack and code can share the page just fine.
> > 
> > BTW., I'm not sure this is necessarily a good idea: it means writable+executable 
> > memory, which we generally try to avoid. How complicated would it be to have them 
> > separate?
> 
> It's trivial: you only need to bump TRAMPOLINE_32BIT_SIZE.
> 
> But it doesn't make much sense. We're running from indentity mapping: all
> memory is r/w without NX bit set (and IA32_EFER.NXE is 0).

Ok, fair enough!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

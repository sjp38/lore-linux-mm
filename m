Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A988828028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:46:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e8so569162wmc.6
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:46:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor3782451wrc.10.2017.11.10.04.46.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 04:46:28 -0800 (PST)
Date: Fri, 10 Nov 2017 13:46:23 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110124623.ou7ccexq2vhuk3c7@gmail.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
 <20171110091703.7izzr7p3jkyxh7vd@gmail.com>
 <20171110092812.ad2i6fj5wmdmheuf@gmail.com>
 <20171110095553.llbcmvaakn56mhzq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110095553.llbcmvaakn56mhzq@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> > One other detail I noticed:
> > 
> >         /* Bound size of trampoline code */
> >         .org    lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE_SIZE
> > 
> > will this generate a build error if the trampoline code exceeds 0x40?
> 
> Yes, this is the point. Just a failsafe if trampoline code would grew too
> much.

Ok, good!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

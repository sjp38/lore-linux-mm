Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5BAB280286
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:52:59 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j15so4720098wre.15
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:52:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x14sor5716626edd.14.2017.11.10.01.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:52:58 -0800 (PST)
Date: Fri, 10 Nov 2017 12:52:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Message-ID: <20171110095256.vmndegdixd5keyqo@node.shutemov.name>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
 <20171110091453.6pk5lotvom2cf4mv@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110091453.6pk5lotvom2cf4mv@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 10, 2017 at 10:14:53AM +0100, Ingo Molnar wrote:
> I'm wondering, how did you test it if no current bootloader puts the kernel to 
> above addresses of 4G?

I didn't test it directly.

I've checked with debugger that there's no memory accesses above 1M
between disabling paging in the trampoline and returning back from
trampoline to the main kernel image code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

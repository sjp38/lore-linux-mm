Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76F6E6B0253
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 12:31:28 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id h3so31212742ybi.1
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 09:31:28 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id j83si11235551wmi.83.2016.08.14.09.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 09:31:27 -0700 (PDT)
Date: Sun, 14 Aug 2016 18:31:26 +0200
From: Pavel Machek 1 <pavel@denx.de>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Message-ID: <20160814163126.GA19472@amd>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
 <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Kralevich <nnk@google.com>
Cc: Jason Cooper <jason@lakedaemon.net>, "Roberts, William C" <william.c.roberts@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

Hi!

> Inter-mmap randomization will decrease the predictability of later
> mmap() allocations, which should help make data structures harder to
> find in memory. In addition, this patch will also introduce unmapped
> gaps between pages, preventing linear overruns from one mapping to
> another another mapping. I am unable to quantify how much this will
> improve security, but it should be > 0.
> 
> I like Dave Hansen's suggestion that this functionality be limited to
> 64 bits, where concerns about running out of address space are
> essentially nil. I'd be supportive of this change if it was limited to
> 64 bits.

Yep, 64bits is easier. But notice that x86-64 machines do _not_ have
full 64bits of address space...

...and that if you use as much address space as possible, TLB flushes
will be slower because page table entries will need more cache.

So this will likely have performance implications even when
application does no syscalls :-(.

How do you plan to deal with huge memory pages support?

Best regards,
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

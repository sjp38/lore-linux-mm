Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB13A6B03A6
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:35:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g70so92358784lfh.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:35:02 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id g141si11857283lfg.86.2017.03.21.12.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 12:35:01 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id a6so70963953lfa.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:35:01 -0700 (PDT)
Date: Tue, 21 Mar 2017 22:34:59 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Message-ID: <20170321193459.GG21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
 <CALCETrWvYERYaNscyQ3Q9rBUvVdzm1do86mMccnZzHsTMEn1HQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWvYERYaNscyQ3Q9rBUvVdzm1do86mMccnZzHsTMEn1HQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 12:31:51PM -0700, Andy Lutomirski wrote:
...
> > I guess the question comes from that we're releasing CRIU 3.0 with
> > 32-bit C/R and some other cool stuff, but we don't support x32 yet.
> > As we don't want release a thing that we aren't properly testing.
> > So for a while we should error on dumping x32 applications.
> 
> I'm curious: shouldn't x32 CRIU just work?  What goes wrong?

Anything ;) We didn't tried as far as I know but i bet
somthing will be broken for sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

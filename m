Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9E036B03A2
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:24:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p78so93501746lfd.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:24:22 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id l17si11821593lfk.97.2017.03.21.12.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 12:24:21 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id z15so70937563lfd.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:24:21 -0700 (PDT)
Date: Tue, 21 Mar 2017 22:24:19 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Message-ID: <20170321192419.GF21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
 <20170321184058.GD21564@uranus.lan>
 <dfdb16d4-aa6e-8635-1ea5-f6ac57b1dd05@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfdb16d4-aa6e-8635-1ea5-f6ac57b1dd05@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 10:19:01PM +0300, Dmitry Safonov wrote:
> > 
> > indeed, thanks!
> 
> Also, even more simple-minded: for now we could just check binary magic
> from /proc/.../exe, for now stopping on x32 binaries.

File may not exist and elfheader wiped out as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

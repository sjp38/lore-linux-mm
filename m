Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53A326B0333
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 18:34:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l37so34503489wrc.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:34:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c197si21831292wmc.40.2017.03.21.15.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 15:34:53 -0700 (PDT)
Date: Tue, 21 Mar 2017 23:34:39 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
In-Reply-To: <26CDE83A-CDBE-4F23-91F6-05B07B461BDD@zytor.com>
Message-ID: <alpine.DEB.2.20.1703212327170.3776@nanos>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com> <alpine.DEB.2.20.1703212319440.3776@nanos> <26CDE83A-CDBE-4F23-91F6-05B07B461BDD@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On Tue, 21 Mar 2017, hpa@zytor.com wrote:

> On March 21, 2017 3:21:13 PM PDT, Thomas Gleixner <tglx@linutronix.de> wrote:
> >On Tue, 21 Mar 2017, Dmitry Safonov wrote:
> >> v3:
> >> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA).
> >
> >For correctness sake, this wants to be cleared in the IA32 path as
> >well. It's not causing any harm, but ....
> >
> >I'll amend the patch.
> >
> >Thanks,
> >
> >	tglx
>
> Since the i386 syscall namespace is totally separate (and different),
> should we simply change the system call number to the appropriate
> sys_execve number?

That should work as well and would be more intuitive.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

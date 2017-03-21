Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA9766B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 18:21:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so5460241wme.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:21:25 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w39si29758741wrc.140.2017.03.21.15.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 15:21:23 -0700 (PDT)
Date: Tue, 21 Mar 2017 23:21:13 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
In-Reply-To: <20170321174711.29880-1-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1703212319440.3776@nanos>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On Tue, 21 Mar 2017, Dmitry Safonov wrote:
> v3:
> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA).

For correctness sake, this wants to be cleared in the IA32 path as
well. It's not causing any harm, but ....

I'll amend the patch.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

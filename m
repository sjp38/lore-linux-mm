Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9936B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:13:44 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so41775220wmv.5
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:13:44 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e8si13762028wrc.310.2017.02.13.05.13.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 05:13:43 -0800 (PST)
Date: Mon, 13 Feb 2017 14:13:21 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 2/5] x86/mm: introduce mmap{,_legacy}_base
In-Reply-To: <696975bb-8846-24b8-e166-b2569d49cec8@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702131411400.3619@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-3-dsafonov@virtuozzo.com> <alpine.DEB.2.20.1702102033420.4042@nanos> <696975bb-8846-24b8-e166-b2569d49cec8@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Mon, 13 Feb 2017, Dmitry Safonov wrote:
> > That just makes me barf, really. I have to go and lookup how TASK_SIZE_MAX
> > is defined in order to read that code. TASK_SIZE_MAX as is does not give a
> > hint at all that it means TASK_SIZE_MAX of 64 bit tasks.
> > 
> > You just explained me that you want stuff proper for clarity reasons. So
> > what's so wrong with adding a helper inline tasksize_64bit() or such?
> 
> I thought about that, but I'll need to redefine it under ifdefs :-/
> I mean, for 32-bit native code.
> Hmm, I think, if I use is32bit parameter for __STACK_RND_MASK(),
> will it be more readable if I just compare to IA32_PAGE_OFFSET here?
> Or does it makes sence to introduce tasksize_32bit()?

Yes, having such a helper makes it immediately clear what this is
about. IA32_PAGE_OFFSET is not really helpful either.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 480CA6B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:35:22 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id n125so67806441vke.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:35:22 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w17si5985506wmw.22.2017.02.13.07.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 07:35:21 -0800 (PST)
Date: Mon, 13 Feb 2017 16:35:10 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 2/5] x86/mm: introduce mmap{,_legacy}_base
In-Reply-To: <adca283e-3187-dff0-7db6-3cb98d6b3bc5@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702131633320.3619@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-3-dsafonov@virtuozzo.com> <alpine.DEB.2.20.1702102033420.4042@nanos> <adca283e-3187-dff0-7db6-3cb98d6b3bc5@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Mon, 13 Feb 2017, Dmitry Safonov wrote:
> On 02/11/2017 05:13 PM, Thomas Gleixner wrote:
> > > -static unsigned long mmap_base(unsigned long rnd)
> > > +static unsigned long mmap_base(unsigned long rnd, unsigned long
> > > task_size)
> > >  {
> > > 	unsigned long gap = rlimit(RLIMIT_STACK);
> > 	unsigned long gap_min, gap_max;
> > 
> > 	/* Add comment what this means */
> > 	gap_min = SIZE_128M + stack_maxrandom_size(task_size);
> > 	/* Explain that ' /6 * 5' magic */
> > 	gap_max = (task_size / 6) * 5;
> 
> So, I can't find about those limits on a gap size:
> They were introduced by commit 8913d55b6c58 ("i386 virtual memory
> layout rework").
> All I could find is that 128Mb limit was more limit on virtual adress
> space than on a memory available those days.
> And 5/6 of task_size looks like heuristic value.
> So I'm not sure, what to write in comments:
> that rlimit on stack can't be bigger than 5/6 of task_size?
> That looks obvious from the code.

So just leave it alone. 5/6 is pulled from thin air and 128M probably as
well. I hoped there would be some reasonable explanation ....

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

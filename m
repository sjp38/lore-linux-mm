Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E30686B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:09:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so1297894wrb.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 07:09:16 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p10si628036wre.41.2017.11.01.07.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 07:09:15 -0700 (PDT)
Date: Wed, 1 Nov 2017 15:09:02 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
In-Reply-To: <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
Message-ID: <alpine.DEB.2.20.1711011506190.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>

On Wed, 1 Nov 2017, Ingo Molnar wrote:
> Beyond the inevitable cavalcade of (solvable) problems that will pop up during 
> review, one major item I'd like to see addressed is runtime configurability: it 
> should be possible to switch between a CR3-flushing and a regular syscall and page 
> table model on the admin level, without restarting the kernel and apps. Distros 
> really, really don't want to double the number of kernel variants they have.

And this removes the !PARAVIRT dependency as well because when the kernel
detects xen_pv() then it simply disables kaiser and all works.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

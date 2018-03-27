Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D77C6B000D
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 16:19:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k17so68755pfj.10
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 13:19:43 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id a7si1375690pgn.327.2018.03.27.13.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 13:19:42 -0700 (PDT)
Subject: Re: [PATCH 00/11] Use global pages with PTI
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
 <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
 <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
 <20180327200719.lvdomez6hszpmo4s@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <a3837d26-031f-6bce-cb1e-f34e5c0cfd2f@linux.intel.com>
Date: Tue, 27 Mar 2018 13:19:40 -0700
MIME-Version: 1.0
In-Reply-To: <20180327200719.lvdomez6hszpmo4s@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 03/27/2018 01:07 PM, Ingo Molnar wrote:
>  - To see at minimum stddev numbers, to make sure we are not looking at some weird
>    statistical artifact. (I also outlined a more robust measurement method.)
> 
>  - If the numbers are right, a CPU engineer should have a look if possible, 
>    because frankly this effect is not expected and is not intuitive. Where global 
>    pages can be used safely they are almost always an unconditional win.
>    Maybe we are missing some limitation or some interaction with PCID.
> 
> Since we'll be using PCID even on Meltdown-fixed hardware, maybe the same negative 
> performance effect already exists on non-PTI kernels as well, we just never 
> noticed?

Yep, totally agree.  I'll do the more robust collection and also explore
on "real" !PCID hardware.  I also know the right CPU folks to go ask
about this, I just want to do the second round of robust data collection
before I bug them.

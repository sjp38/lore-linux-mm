Date: Wed, 21 Jun 2000 16:43:57 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <200006212141.OAA54650@google.engr.sgi.com>
References: <20000621213507Z131177-21003+34@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 04:28:43 PM
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621215037Z131177-21004+47@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
Jun 2000 14:41:16 -0700 (PDT)


> Which is hard to do with all the various architectures with varying
> cache line sizes out there. The asm header files can conveniently use
> __attribute__((aligned(128))) etc, but I think the generic header files
> use something like __attribute__((__aligned__(SMP_CACHE_BYTES))).
> Note that SMP_CACHE_BYTES is equated to the >> L1 << cache size for
> most architectures, which probably has a different effect than 
> aligning on L2 cache lines.

Is the majority of the kernel cache-line aligned like this, or is this an area
where the kernel needs a lot of work?  




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

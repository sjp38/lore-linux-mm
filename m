Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 529746B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 16:01:54 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w191so36392982iof.11
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:01:54 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l23si21831502iog.279.2017.11.27.13.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 13:01:53 -0800 (PST)
Date: Mon, 27 Nov 2017 22:01:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 3/4] x86/mm/debug_pagetables: Use octal file permissions
Message-ID: <20171127210145.7hfxwc6gbnb62dja@hirez.programming.kicks-ass.net>
References: <20171127203416.236563829@linutronix.de>
 <20171127204257.654262031@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127204257.654262031@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Mon, Nov 27, 2017 at 09:34:19PM +0100, Thomas Gleixner wrote:
> As equested by several reviewers.
> 
> Fixes: ca646ac417b8 ("x86/mm/debug_pagetables: Allow dumping current pagetables")
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Thanks! ACK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

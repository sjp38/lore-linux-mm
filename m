Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86C7F6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:57:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g29so7916777pfk.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:57:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x4si22545642plw.539.2017.11.27.01.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 01:57:45 -0800 (PST)
Date: Mon, 27 Nov 2017 10:57:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
Message-ID: <20171127095737.ocolhqaxsaboycwa@hirez.programming.kicks-ass.net>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.313869499@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171126232414.313869499@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 12:14:04AM +0100, Thomas Gleixner wrote:
> PAGE_NX and PAGE_GLOBAL might be not supported or disabled on the command
> line, but KAISER sets them unconditionally.

So KAISER is x86_64 only, right? AFAIK there is no x86_64 without NX
support. So would it not make sense to mandate NX for KAISER?, that is
instead of making "noexec" + KAISER work, make "noexec" kill KAISER +
emit a warning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

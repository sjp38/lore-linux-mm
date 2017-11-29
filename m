Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B05456B027E
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:27:25 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k104so2078413wrc.19
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:27:25 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 88si1793947edy.434.2017.11.29.06.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 06:27:24 -0800 (PST)
Date: Wed, 29 Nov 2017 15:26:55 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 0/6] more KAISER bits
In-Reply-To: <20171129103301.131535445@infradead.org>
Message-ID: <alpine.DEB.2.20.1711291523340.1825@nanos>
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Wed, 29 Nov 2017, Peter Zijlstra wrote:

> Here's more patches, includes the TLB invalidate rework.
> 
> Has not actually been tested on a INVPCID machine yet, but does seem to
> work fine on my IVB-EP (which is PCID only).

I've picked all of that up including other bits and pieces which have been
circulated in various threads.

Note that the next series will have

 - a rename as lots of people complained about KAISER

 - stuff folded back where ever it makes sense
 
 - reordering of the queue to put fixes and preparatory changes first

Will take a bit, but this needs to be done before I completely drown in
conflicting patches and patch snippets of all sorts.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

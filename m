Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BBFC48D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 18:36:34 -0400 (EDT)
Date: 16 Mar 2011 18:36:31 -0400
Message-ID: <20110316223631.20091.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
In-Reply-To: <alpine.DEB.2.00.1103161352150.11002@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, rientjes@google.com
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

> Patches that you would like to propose but don't think are ready for merge 
> should have s/PATCH/RFC/ done on the subject line.

You're right; I should have.  I blame git-format-patch's defaults, but mea culpa.
(Now I know about the --subject-prefix=RFC option!)

> You deliberately created a helper function to take an unsigned int when 
> the actuals being passed in are all unsigned long to trigger a discussion 
> on why they are unsigned long?

Er, no, I'm not that Machiavellian.
I deliberately did it because it was obvious that the flags would always
fit into an "unsigned", so I didn't need "unsigned long".

(Actually, I owe you an apology; when writing that e-mail, I remember
thinking "I should go back and clarify that statement", but forgot before
hitting send.)

> unsigned long uses the native word size of the architecture which can 
> generate more efficient code; we typically imply that flags have a limited 
> size by including leading zeros in their definition for 32-bit 
> compatibility:

Um, can you name a (64-bit) architecture on which 32-bit is more
expensive than 64-bit?  On x86-64, it's potentially cheaper, and even
the infamous Alpha 21064 has no penalty for 32-bit accesses.  SPARC,
MIPS, PPC, Itanium, what else?  I don't know about z/ARchitecture,
but given the emphasis on backward compatibility in IBM's mainframes,
it seems hard to imagine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

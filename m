Date: Mon, 9 Oct 2000 18:34:03 -0400 (EDT)
From: Byron Stanoszek <gandalf@winds.org>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler 
In-Reply-To: <200010092208.e99M8CE14230@eng2.sequent.com>
Message-ID: <Pine.LNX.4.21.0010091829140.7807-100000@winds.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000 Gerrit.Huizenga@us.ibm.com wrote:

> Anyway, there is/was an API in PTX to say (either from in-kernel or through
> some user machinations) "I Am a System Process".  Turns on a bit in the
> proc struct (task struct) that made it exempt from death from a variety
> of sources, e.g. OOM, generic user signals, portions of system shutdown,
> etc.

The current OOM killer does this, except for init. Checking to see if the
process has a page table is equivalent to checking for the kernel threads that
are integral to the system (PIDs 2-5). These will never be killed by the OOM.
Init, however, still can be killed, and there should be an additional statement
that doesn't kill if PID == 1.

I think we need to sit down and write a better OOM proposal, something that
doesn't use CPU time and the NICE flag. Lets concentrate our efforts on what
constitutes a good selection method instead of bickering with each other.

How about we start by everyone in this discussion give their opinion on what
the OOM selection process should do, listing them in both order of importance
and severity, giving a rational reason for each choice. Maybe then we can get
somewhere.

 -Byron

-- 
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: bstanoszek@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

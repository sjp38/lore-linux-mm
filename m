Date: Mon, 9 Oct 2000 21:38:08 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010092223100.8045-100000@elte.hu>
Message-ID: <Pine.SOL.4.21.0010092137140.7984-100000@green.csi.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Ingo Molnar wrote:

> On Mon, 9 Oct 2000, Rik van Riel wrote:
> 
> > > so dns helper is killed first, then netscape. (my idea might not
> > > make sense though.)
> > 
> > It makes some sense, but I don't think OOM is something that
> > occurs often enough to care about it /that/ much...
> 
> i'm trying to handle Andrea's case, the init=/bin/bash manual-bootup case,
> with 4MB RAM and no swap, where the admin tries to exec a 2MB process. I
> think it's a legitimate concern - i cannot know in advance whether a
> freshly started process would trigger an OOM or not.

Shouldn't the runtime factor handle this, making sure the new process is
killed? (Maybe not if you're almost OOM right from the word go, and run
this process straight off... Hrm.)


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

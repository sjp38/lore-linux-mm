Date: Mon, 9 Oct 2000 22:44:39 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009224439.L19583@athlon.random>
References: <Pine.LNX.4.21.0010092223100.8045-100000@elte.hu> <Pine.SOL.4.21.0010092137140.7984-100000@green.csi.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SOL.4.21.0010092137140.7984-100000@green.csi.cam.ac.uk>; from jas88@cam.ac.uk on Mon, Oct 09, 2000 at 09:38:08PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Andi Kleen <ak@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 09:38:08PM +0100, James Sutherland wrote:
> Shouldn't the runtime factor handle this, making sure the new process is

The runtime factor in the algorithm will make the first difference
only after lots lots of time (and the run_time can as well be wrong
because of jiffies wrap around). But even if it would make a difference
after 1 second, there would be a 1 second window where init can be killed.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 9 Oct 2000 22:06:06 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009220606.A20457@gruyere.muc.suse.de>
References: <20001009214214.G19583@athlon.random> <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>; from mingo@elte.hu on Mon, Oct 09, 2000 at 10:06:02PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 10:06:02PM +0200, Ingo Molnar wrote:
> 
> On Mon, 9 Oct 2000, Andrea Arcangeli wrote:
> 
> > > No. It's only needed if your OOM algorithm is so crappy that
> > > it might end up killing init by mistake.
> > 
> > The algorithm you posted on the list in this thread will kill init if
> > on 4Mbyte machine without swap init is large 3 Mbytes and you execute
> > a task that grows over 1M.
> 
> i think the OOM algorithm should not kill processes that have
> child-processes, it should first kill child-less 'leaves'. Killing a
> process that has child processes likely results in unexpected behavior of
> those child-processes. (and equals to effective killing of those
> child-processes as well.)

netscape usually has child processes: the dns helper. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 25 Sep 2000 17:01:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925170113.S22882@athlon.random>
References: <20000925163909.O22882@athlon.random> <Pine.LNX.4.21.0009251640330.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251640330.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 04:43:44PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:43:44PM +0200, Ingo Molnar wrote:
> i talked about GFP_KERNEL, not GFP_USER. Even in the case of GFP_USER i

My bad, you're right I was talking about GFP_USER indeed.

But even GFP_KERNEL allocations like the init of a module or any other thing
that is static sized during production just checking the retval looks be ok.

> believe the right place to oom is via a signal, not in the gfp() case.

Signal can be trapped and ignored by malicious task. We had that security
problem until 2.2.14 IIRC.

> (because oom situation in the gfp() case is a completely random and
> statistical event, which might have no connection at all to the behavior
> of that given process.)

I agree we should have more information about the behaviour of the system
and I think a per-task page fault rate should work in practice.

But my question isn't what you do when you're OOM, but is _how_ do you
notice that you're OOM?

In the GFP_USER case simply checking when GFP fails looks right to me.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

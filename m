Subject: Re: [PATCH] generalized spin_lock_bit
From: Robert Love <rml@tech9.net>
In-Reply-To: <20020720211539.GG1096@holomorphy.com>
References: <1027196511.1555.767.camel@sinai>
	<Pine.LNX.4.44.0207201335560.1492-100000@home.transmeta.com>
	<20020720211539.GG1096@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Jul 2002 14:19:31 -0700
Message-Id: <1027199971.1555.797.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Sat, 2002-07-20 at 14:15, William Lee Irwin III wrote:

> I was hoping to devolve the issue of the implementation of it to arch
> maintainers by asking for this. I was vaguely aware that the atomic bit
> operations are implemented via hashed spinlocks on PA-RISC and some
> others, so by asking for the right primitives to come back up from arch
> code I hoped those who spin elsewhere might take advantage of their
> window of exclusive ownership.

Yah, me too ;)

> Would saying "Here is an address, please lock it, and if you must flip
> a bit, use this bit" suffice? I thought it might give arch code enough
> room to wiggle, but is it enough?

I would prefer to do nothing right now.  We can implement the general
interface but keep the pte_chain_lock abstraction.  Individual
architectures can optimize their bitwise locking.

If that does not suffice and their is a REAL problem in the future we
can look to a better approach...

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

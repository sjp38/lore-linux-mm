Date: Mon, 25 Sep 2000 11:36:53 -0500 (CDT)
From: Jeff Garzik <jgarzik@mandrakesoft.mandrakesoft.com>
Subject: Re: the new VMt
In-Reply-To: <Pine.GSO.4.21.0009251217020.16980-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.3.96.1000925112046.2414G-100000@mandrakesoft.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Ingo Molnar <mingo@elte.hu>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alexander Viro wrote:
> On Mon, 25 Sep 2000, Ingo Molnar wrote:
> > yep, i agree. I'm not sure what the biggest allocation is, some drivers
> > might use megabytes or contiguous RAM?

> Stupidity has no limits...

Blame the hardware designers... and give me my big allocations. :)

Sounds drivers (not mine though, <g>) do stuff like

	order = 20; /* just a made-up high number*/
	while ((order-- > 0) && (mem == NULL)) {
		mem = __get_free_pages (GFP_KERNEL, order);
	}
	/* use sound buffer 'mem' */

Older or modern, less-than-cool framegrabbers need tons of contiguous
memory too...

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

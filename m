Date: Tue, 22 Apr 2003 17:16:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422151621.GJ23320@dualathlon.random>
References: <Pine.LNX.4.44.0304220618190.24063-100000@devserv.devel.redhat.com> <170570000.1051021741@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <170570000.1051021741@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 07:29:02AM -0700, Martin J. Bligh wrote:
> overhead itself. I think we're optimising for the wrong case here - isn't
> the 100x100 mappings case exactly what we have sys_remap_file_pages for?

yes IMHO.

> We can make the O(?) stuff look as fancy as we like. However, in reality,
> that makes the constants suck, and I'm not at all sure it's a good plan.

correct, it depends on what we care to run fast.

> It seems ironic that the solution to space consumption is do double the
> amount of space taken ;-) I see what you're trying to do (shove things up

Agreed.

> I think the holes in objrmap are quite small - and are already addressed by
> your sys_remap_file_pages mechanism.

Yep.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

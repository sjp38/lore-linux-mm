Date: Mon, 02 Aug 2004 16:06:40 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: tmpfs round-robin NUMA allocation
Message-ID: <151460000.1091488000@flay>
In-Reply-To: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>, linux-mm@kvack.org
Cc: hugh@veritas.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

> I looked at using the MPOL_INTERLEAVE policy to accomplish this,
> however I think there's a flaw with that approach.  Since that
> policy uses the vm_pgoff value (which for tmpfs is determined by
> the inode swap page index) to determine the node from which to
> allocate, it seems that we'll overload the first few available
> nodes for interleaving instead of evenly distributing pages.
> This will be particularly exacerbated if there are a large number
> of small files in the tmpfs filesystem.

...

> So, the big decision is whether I should put the round-robining
> into tmpfs itself, or write the more general mechanism for the
> NUMA memory policy code.

Doesn't really seem like a tmpfs problem - I'd think the general
mod would be more appropriate. But rather than creating another
policy, would it not be easier to just add a static "node offset"
on a per-file basis (ie make them all start on different nodes)?
Either according to the node we created the file from, or just
a random node?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

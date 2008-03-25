MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18408.59112.945786.488350@cargo.ozlabs.ibm.com>
Date: Tue, 25 Mar 2008 22:50:00 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: larger default page sizes...
In-Reply-To: <20080324.211532.33163290.davem@davemloft.net>
References: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<20080324.211532.33163290.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

David Miller writes:

> From: Paul Mackerras <paulus@samba.org>
> Date: Tue, 25 Mar 2008 14:29:55 +1100
> 
> > The performance advantage of using hardware 64k pages is pretty
> > compelling, on a wide range of programs, and particularly on HPC apps.
> 
> Please read the rest of my responses in this thread, you
> can have your HPC cake and eat it too.

It's not just HPC, as I pointed out, it's pretty much everything,
including kernel compiles.  And "use hugepages" is a pretty inadequate
answer given the restrictions of hugepages and the difficulty of using
them.  How do I get gcc to use hugepages, for instance?  Using 64k
pages gives us a performance boost for almost everything without the
user having to do anything.

If the hugepage stuff was in a state where it enabled large pages to
be used for mapping an existing program, where possible, without any
changes to the executable, then I would agree with you.  But it isn't,
it's a long way from that, and (as I understand it) Linus has in the
past opposed the suggestion that we should move in that direction.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

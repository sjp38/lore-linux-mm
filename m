Date: Tue, 15 Feb 2005 07:38:46 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
 sys_page_migrate
Message-Id: <20050215073846.435e5a0a.pj@sgi.com>
In-Reply-To: <20050215105056.GC19658@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	<20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
	<1108242262.6154.39.camel@localhost>
	<20050214135221.GA20511@lnx-holt.americas.sgi.com>
	<1108407043.6154.49.camel@localhost>
	<20050214220148.GA11832@lnx-holt.americas.sgi.com>
	<1108419774.6154.58.camel@localhost>
	<20050215105056.GC19658@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: haveblue@us.ibm.com, raybry@sgi.com, taka@valinux.co.jp, hugh@veritas.com, akpm@osdl.org, marcello@cyclades.com, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Robin wrote:
> Given that the first user of this may place in onto a 256 node system,
> the chances that they use the same node in the source and destination node
> array are very good.

Am I parsing this sentence correctly when I read it as stating that we
need to handle the case where the source and destination node sets
overlap (have non-empty intersection)?

> I can not see the node array as anything but the right way
> when compared to multiple system calls.

Variable length arrays across the system call boundary are a pain in the
butt.  Especially ones that add what are essentially "new types", in this
case, an array of MAX_NUMNODES node numbers.  Odds are well over 50% that
there will be a bug in this area, in our lifetime.

And simplicity is measured more, in my mind, by whether each specific
system call does the essential minimum of work, with clear pre and post
conditions, than by whether the caller is able to make the fewest number
of such calls.  Such reduction to the smallest irreducible atoms of work
both ensures that the kernel is best able to maintain order, and that it
can be used in the most flexible, unforseeable patterns possible,
without further kernel changes.

Such a node array call may well make good sense as a library API.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

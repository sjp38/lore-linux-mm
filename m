Date: Wed, 8 Dec 2004 13:42:46 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
In-Reply-To: <20041208132627.1c73177e.davem@davemloft.net>
Message-ID: <Pine.LNX.4.58.0412081341230.31040@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <20041202101029.7fe8b303.cliffw@osdl.org> <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
 <200412080933.13396.jbarnes@engr.sgi.com> <Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
 <20041208132627.1c73177e.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Christoph Lameter <clameter@sgi.com>, jbarnes@engr.sgi.com, nickpiggin@yahoo.com.au, jgarzik@pobox.com, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 8 Dec 2004, David S. Miller wrote:
> 
> I see.  Yet I noticed that while the patch makes system time decrease,
> for some reason the wall time is increasing with the patch applied.
> Why is that, or am I misreading your tables?

I assume that you're looking at the final "both patches applied" case.

It has ten repetitions, while the other two tables only have three. That 
would explain the discrepancy.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

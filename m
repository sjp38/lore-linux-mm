Date: Mon, 28 Apr 2008 11:13:47 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080428101347.GA5401@shadowen.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080425173827.GC9680@us.ibm.com> <20080425175503.GG3265@one.firstfloor.org> <20080425175249.GE9680@us.ibm.com> <20080425181056.GH3265@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425181056.GH3265@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org
Cc: npiggin@suse.de, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 08:10:56PM +0200, Andi Kleen wrote:
> On Fri, Apr 25, 2008 at 10:52:49AM -0700, Nishanth Aravamudan wrote:
> > On 25.04.2008 [19:55:03 +0200], Andi Kleen wrote:
> > > > Unnecessary initializations (and whitespace)?
> > > 
> > > Actually gcc generates exactly the same code for 0 and no
> > > initialization.
> > 
> > All supported gcc's? Then checkpatch should be fixed?
> 
> 3.3-hammer did it already, 3.2 didn't. 3.2 is nominally still
> supposed but I don't think we care particularly about its code
> quality.
> 
> Yes checkpatch should be fixed.

Cirtainly on this 4.1.2 I randomly picked to test, the size of the data
segment seems unchanged by initialisation to zero.  It ends up in the
BSS as expected.

So I guess the question is do we want to maintain this recommendation
for consistency or has it outlived its usefulness?

Opinions?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

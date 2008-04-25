Date: Fri, 25 Apr 2008 20:10:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080425181056.GH3265@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080425173827.GC9680@us.ibm.com> <20080425175503.GG3265@one.firstfloor.org> <20080425175249.GE9680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425175249.GE9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 10:52:49AM -0700, Nishanth Aravamudan wrote:
> On 25.04.2008 [19:55:03 +0200], Andi Kleen wrote:
> > > Unnecessary initializations (and whitespace)?
> > 
> > Actually gcc generates exactly the same code for 0 and no
> > initialization.
> 
> All supported gcc's? Then checkpatch should be fixed?

3.3-hammer did it already, 3.2 didn't. 3.2 is nominally still
supposed but I don't think we care particularly about its code
quality.

Yes checkpatch should be fixed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

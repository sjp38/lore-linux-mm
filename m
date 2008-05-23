Date: Fri, 23 May 2008 14:34:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523123436.GA25172@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com> <20080523054133.GO13071@wotan.suse.de> <20080523104327.GG31727@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523104327.GG31727@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, May 23, 2008 at 12:43:27PM +0200, Andi Kleen wrote:
> > For that matter, I'm almost inclined to submit the patchset with
> > only allow one active hstate specified on the command line, and no
> > changes to any sysctls... just to get the core code merged sooner ;)
> 
> If you do that you don't really need to bother with the patchset.
> I had an earlier patch for GB pages in hugetlbfs that only supported
> a single page size and it was much much simpler. All the work just came
> from supporting multiple page sizes for binary compatibility.

Oh, maybe you misunderstand what I meant: I think the multiple hugepages
stuff is nice, and definitely should go in. But I think that if there is
any more disagreement over the userspace APIs, then we should just merge
the patchset anyway just without any changes to the APIs -- at least that
way we'll have most of the code ready for when an agreement can be
reached.

However I say *almost*, because hopefully we can agree on the API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 23 Apr 2008 18:02:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Message-ID: <20080423160223.GG16769@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org> <20080423155338.GF16769@wotan.suse.de> <20080423160210.GC29087@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423160210.GC29087@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 06:02:10PM +0200, Andi Kleen wrote:
> > No, it can generally determine the size of the hugepages. It would
> > be more wrong (but probably more common) for portable code to assume
> 
> For compatibility we have to assume code does that.
 
True, and that's definitely what it does by default. But the option is
there for people to ask for 1G pages as the primary size, in which case
well written and legacy applications will be able to use them. I assume
most important Java HPC and database codes will be because they are
multi platform and at the very least they would have to deal with 2MB
and 4MB hugepages for x86.


> > 2MB hugepages.
> 
> Well then it should just run with 2MB pages on a kernel where both
> 1G and 2M are configured. Does it not do that? 

Yes, if you ask for 1G and 2M it will run with them OK.

 
> > If you want your legacy userspace to have 2MB hugepages, then you would
> 
> I think all legacy user space should only use 2MB huge pages.

Why? You would be wary of bugs coming up? 

Anyway, I'm sure it is not a problem to just allow the opportunity to
have 1GB as primary page size. Of course it will be 2MB only by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

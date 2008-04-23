Date: Wed, 23 Apr 2008 18:02:10 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Message-ID: <20080423160210.GC29087@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org> <20080423155338.GF16769@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423155338.GF16769@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> No, it can generally determine the size of the hugepages. It would
> be more wrong (but probably more common) for portable code to assume

For compatibility we have to assume code does that.

> 2MB hugepages.

Well then it should just run with 2MB pages on a kernel where both
1G and 2M are configured. Does it not do that? 

> If you want your legacy userspace to have 2MB hugepages, then you would

I think all legacy user space should only use 2MB huge pages.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

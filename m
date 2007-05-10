Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070509231937.ea254c26.akpm@linux-foundation.org>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	 <20070430.150407.07642146.davem@davemloft.net>
	 <1177977619.24962.6.camel@localhost.localdomain>
	 <20070430.173806.112621225.davem@davemloft.net>
	 <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
	 <1177985136.24962.8.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0705011453380.4771@mtfhpc.demon.co.uk>
	 <1178055110.13263.2.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
	 <20070509231937.ea254c26.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 10 May 2007 16:29:43 +1000
Message-Id: <1178778583.14928.210.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Fortescue <mark@mtfhpc.demon.co.uk>, David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> We never seemed to reach completion here?

Well, I'm waiting for other people comments too... as I said earlier,
I'm not too fan of burrying the update_mmu_cache() inside
ptep_set_access_flags(), but perhaps we could remove the whole logic of
reading the old PTE & comparing it, and instead have
ptep_set_access_flags() do that locally and return to the caller wether
a change occured that requires update_mmu_cache() to be called.

That way, archs who don't actually need update_mmu_cache() under some
circumstances will be able to return 0 there.

What do you guys thing ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

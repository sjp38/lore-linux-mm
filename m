Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	 <20070430.150407.07642146.davem@davemloft.net>
	 <1177977619.24962.6.camel@localhost.localdomain>
	 <20070430.173806.112621225.davem@davemloft.net>
	 <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Tue, 01 May 2007 12:05:36 +1000
Message-Id: <1177985136.24962.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> At present, update_mmu_cache() and lazy_mmu_prot_update() are always 
> called when ptep_set_access_flags() is called so why not move them into 
> ptep_set_access_flags() and change ptep_set_access_flags() to have an 
> additional boolean parameter (__update) that would when set, cause 
> update_mmu_cache() and lazy_mmu_prot_update() to be called.

Well, ptep_set_access_flags() is a low level arch hook, I'd rather not
start hiding update_mmu_cache() calls in it ...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

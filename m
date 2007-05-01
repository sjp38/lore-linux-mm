Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.61.0705011453380.4771@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	 <20070430.150407.07642146.davem@davemloft.net>
	 <1177977619.24962.6.camel@localhost.localdomain>
	 <20070430.173806.112621225.davem@davemloft.net>
	 <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
	 <1177985136.24962.8.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0705011453380.4771@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Wed, 02 May 2007 07:31:50 +1000
Message-Id: <1178055110.13263.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I have attached a patch (so pine does not mangle it) for linux-2.6.20.9.
> Is this what you had in mind?
> 
> For linux-2.6.21, more work will be needed as it has more code calling 
> ptep_set_access_flags.

I'm not 100% sure we need the 'update' argument... we can remove the
whole old_entry, pte_same, etc... and just have pte_set_access_flags()
read the old PTE and decide wether something needs to be changed or not.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

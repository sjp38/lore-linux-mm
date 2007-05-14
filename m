Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
	 <20070509231937.ea254c26.akpm@linux-foundation.org>
	 <1178778583.14928.210.camel@localhost.localdomain>
	 <20070510.001234.126579706.davem@davemloft.net>
	 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Tue, 15 May 2007 07:07:25 +1000
Message-Id: <1179176845.32247.107.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 20:19 +0100, Hugh Dickins wrote:
> On Thu, 10 May 2007, David Miller wrote:
> > > > We never seemed to reach completion here?
> > > 
> > > Well, I'm waiting for other people comments too... as I said earlier,
> > > I'm not too fan of burrying the update_mmu_cache() inside
> > > ptep_set_access_flags(), but perhaps we could remove the whole logic of
> > > reading the old PTE & comparing it, and instead have
> > > ptep_set_access_flags() do that locally and return to the caller wether
> > > a change occured that requires update_mmu_cache() to be called.
> > > 
> > > That way, archs who don't actually need update_mmu_cache() under some
> > > circumstances will be able to return 0 there.
> > > 
> > > What do you guys thing ?
> > 
> > I think that's a good idea.
> 
> I agree.

Ok, I'll cook a patch today.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

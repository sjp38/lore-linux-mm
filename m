Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0705230438490.14106@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
	 <20070509231937.ea254c26.akpm@linux-foundation.org>
	 <1178778583.14928.210.camel@localhost.localdomain>
	 <20070510.001234.126579706.davem@davemloft.net>
	 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
	 <1179176845.32247.107.camel@localhost.localdomain>
	 <1179212184.32247.163.camel@localhost.localdomain>
	 <1179757647.6254.235.camel@localhost.localdomain>
	 <1179815339.32247.799.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705221738020.22822@blonde.wat.veritas.com>
	 <1179874748.32247.868.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705230438490.14106@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 23 May 2007 14:21:45 +1000
Message-Id: <1179894105.32247.904.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-23 at 05:03 +0100, Hugh Dickins wrote:
> 
> No, I wasn't meaning the optimization, but the significance of the
> boolean __changed that's returned.  If ptep_set_access_flags does
> not change the pte (because !dirty or !safely_writable or whatever
> that arch calls it), then ideally it ought to return false.

Hrm... I prefer keeping the existing semantics. The old code used to
always update_mmu_cache() on those archs and I'd rather let it continue
do so unless the arch maintainer who knows better changes it :-)
 
> But it doesn't affect correctness if it sometimes says true not
> false, and these arches happen to have an empty update_mmu_cache
> (with lazy_mmu_prot_update currently under separate review), and
> what you have follows what was already being done, and sun4c
> already has to "lie": so it's rather theoretical. 

Ok.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

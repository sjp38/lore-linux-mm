Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: "Tom \"spot\" Callaway" <tcallawa@redhat.com>
In-Reply-To: <1179874748.32247.868.camel@localhost.localdomain>
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
Content-Type: text/plain
Date: Tue, 22 May 2007 18:04:54 -0500
Message-Id: <1179875094.6254.310.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-23 at 08:59 +1000, Benjamin Herrenschmidt wrote:

> Well, I don't know which is why I'm waiting for Tom Callaway to test.
> Davem mentioned update_mmu_cache only though when we discussed the
> problem initially.

Mark already tested it and said it worked for him. This is sufficient
for me, as I'm not sure how many Aurora sun4c users there actually are.
If the extra bit turns out to be needed, I can push an update.

~spot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

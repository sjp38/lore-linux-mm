Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B378D6B03D6
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:40:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u8so171244535pgo.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:40:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 101si1670449ple.204.2017.06.21.03.40.23
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 03:40:23 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:40:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170621104016.GB10220@e104818-lin.cambridge.arm.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
 <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
 <20170619160005.wgj4nymtj2nntfll@node.shutemov.name>
 <20170619170911.GF3024@e104818-lin.cambridge.arm.com>
 <20170619215210.2crwjou3sfdcj73d@node.shutemov.name>
 <20170620155438.GC21383@e104818-lin.cambridge.arm.com>
 <20170621095303.q5fqt5a3ao5smko6@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170621095303.q5fqt5a3ao5smko6@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 21, 2017 at 12:53:03PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jun 20, 2017 at 04:54:38PM +0100, Catalin Marinas wrote:
> > For arm64, I don't see the point of a cmpxchg, so something like below
> > would do (it needs proper testing though):
> 
> Right. cmpxchg is required for x86 PAE, as it has sizeof(pmd_t) >
> sizeof(long). We don't have 8-byte xchg() there.
> 
> Thanks, for the patch. I assume, I can use your signed-off-by, right?

Yes. And maybe some text (well, I just copied yours):

---------------8<--------------
arm64: Provide pmdp_establish() helper

We need an atomic way to setup pmd page table entry, avoiding races with
CPU setting dirty/accessed bits. This is required to implement
pmdp_invalidate() that doesn't lose these bits.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---------------8<--------------

> Any chance you could help me with arm too?

I'll have a look.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

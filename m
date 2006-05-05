Received: from blonde.wat.veritas.com([10.10.97.26]) (1456 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1FbzcV-0001s0C@megami.veritas.com>
	for <linux-mm@kvack.org>; Fri, 5 May 2006 05:41:19 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Fri, 5 May 2006 13:41:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Any reason for passing "tlb" to "free_pgtables()" by address?
In-Reply-To: <445B2EBD.4020803@bull.net>
Message-ID: <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com>
References: <445B2EBD.4020803@bull.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On Fri, 5 May 2006, Zoltan Menyhart wrote:
> Apparently, there is no reason for passing "tlb" to "free_pgtables()"
> by address, because there is no need for re-scheduling inside this
> function => no other "mmu_gather" can / will be used.

You're right.  Well, actually, it's been shown that there _is_ a need
for rescheduling inside that function (high latency), but we've not
yet settled on the right way to go about that - mmu_gathering needs
overhaul to avoid disabling preemption, something both Nick and I
have worked on intermittently.

Personally I'd prefer not to make your change right now - it seems
a shame to make that cosmetic change without addressing the real
latency issue; but I've no strong feeling against your patch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

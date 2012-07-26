Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 87A7D6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 15:42:57 -0400 (EDT)
Message-ID: <1343331770.32120.6.camel@twins>
Subject: Re: [RFC][PATCH 0/2] fun with tlb flushing on s390
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 26 Jul 2012 21:42:50 +0200
In-Reply-To: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
References: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, Zachary Amsden <zach@vmware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On Thu, 2012-07-26 at 17:47 +0200, Martin Schwidefsky wrote:
> A code review revealed another potential race in regard to TLB flushing
> on s390. See patch #2 for the ugly details. To fix this I would like
> to use the arch_enter_lazy_mmu_mode/arch_leave_lazy_mmu_mode but to do
> that the pointer to the mm in question needs to be added to the functions=
.
> To keep things symmetrical arch_flush_lazy_mmu_mode should grow an mm
> argument as well.
>=20
> powerpc=20

I have a patch that makes sparc64 do the same thing.

> and x86 have a non-empty implementation for the lazy mmu flush
> primitives and tile calls the generic definition in the architecture
> files (which is a bit strange because the generic definition is empty).
> Comments?

argh.. you're making my head hurt.

I guess my first question is where is lazy_mmu_mode active crossing an
mm? I thought it was only ever held across operations on a single mm.

The second question would be if you could use that detach_mm thing I
proposed a while back ( http://marc.info/?l=3Dlinux-mm&m=3D134090072917840 =
)
or can we rework the active_mm magic in general to make all this easier?

Your 2/2 patch makes me shiver..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

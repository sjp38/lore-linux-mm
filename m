Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8CED86B02BD
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 19:25:14 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n1so20223090pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 16:25:14 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id l79si89053pfj.200.2016.04.05.16.25.13
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 16:25:13 -0700 (PDT)
Date: Tue, 05 Apr 2016 19:25:07 -0400 (EDT)
Message-Id: <20160405.192507.1323523820451519013.davem@davemloft.net>
Subject: Re: [PATCH 10/10] arch: fix has_transparent_hugepage()
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
	<alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, andreslc@google.com, yang.shi@linaro.org, quning@gmail.com, arnd@arndb.de, ralf@linux-mips.org, vgupta@synopsys.com, linux@arm.linux.org.uk, will.deacon@arm.com, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, schwidefsky@de.ibm.com, gerald.schaefer@de.ibm.com, cmetcalf@tilera.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

From: Hugh Dickins <hughd@google.com>
Date: Tue, 5 Apr 2016 14:02:49 -0700 (PDT)

> I've just discovered that the useful-sounding has_transparent_hugepage()
> is actually an architecture-dependent minefield: on some arches it only
> builds if CONFIG_TRANSPARENT_HUGEPAGE=y, on others it's also there when
> not, but on some of those (arm and arm64) it then gives the wrong answer;
> and on mips alone it's marked __init, which would crash if called later
> (but so far it has not been called later).
> 
> Straighten this out: make it available to all configs, with a sensible
> default in asm-generic/pgtable.h, removing its definitions from those
> arches (arc, arm, arm64, sparc, tile) which are served by the default,
> adding #define has_transparent_hugepage has_transparent_hugepage to those
> (mips, powerpc, s390, x86) which need to override the default at runtime,
> and removing the __init from mips (but maybe that kind of code should be
> avoided after init: set a static variable the first time it's called).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

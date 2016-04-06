Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD226B026F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:57:08 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id v188so20153332wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:57:08 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id m6si22461781wmf.86.2016.04.06.04.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:57:07 -0700 (PDT)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 6 Apr 2016 12:57:06 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2BF661B08070
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:57:42 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u36Bv4ur8126772
	for <linux-mm@kvack.org>; Wed, 6 Apr 2016 11:57:04 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u36Bv2p4004007
	for <linux-mm@kvack.org>; Wed, 6 Apr 2016 07:57:03 -0400
Date: Wed, 6 Apr 2016 13:56:59 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 10/10] arch: fix has_transparent_hugepage()
Message-ID: <20160406135659.29846d02@thinkpad>
In-Reply-To: <alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
	<alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Arnd Bergman <arnd@arndb.de>, Ralf Baechle <ralf@linux-mips.org>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, 5 Apr 2016 14:02:49 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

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
> ---

Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com> # for arch/s390 bits

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6776B057F
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 20:46:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r187so32001248pfr.8
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 17:46:19 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id c73si404196pfk.462.2017.08.01.17.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 17:46:17 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id e3so4255419pfc.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 17:46:17 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 1/4] mm: refactoring TLB gathering API
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170801103032.h7tnxryoxx7k7aqg@techsingularity.net>
Date: Tue, 1 Aug 2017 17:46:14 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <59138710-3EFB-4D59-BD5B-D97CAFEBF098@gmail.com>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-2-git-send-email-minchan@kernel.org>
 <20170801103032.h7tnxryoxx7k7aqg@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, kernel-team <kernel-team@lge.com>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

Mel Gorman <mgorman@techsingularity.net> wrote:

> On Tue, Aug 01, 2017 at 02:56:14PM +0900, Minchan Kim wrote:
>> This patch is ready for solving race problems caused by TLB batch.
>=20
> s/is ready/is a preparatory patch/
>=20
>> For that, we will increase/decrease TLB flush pending count of
>> mm_struct whenever tlb_[gather|finish]_mmu is called.
>>=20
>> Before making it simple, this patch separates architecture specific
>> part and rename it to arch_tlb_[gather|finish]_mmu and generic part
>> just calls it.
>>=20
>> It shouldn't change any behavior.
>>=20
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: Russell King <linux@armlinux.org.uk>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>> Cc: Jeff Dike <jdike@addtoit.com>
>> Cc: linux-arch@vger.kernel.org
>> Cc: Nadav Amit <nadav.amit@gmail.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>=20
> You could alias arch_generic_tlb_finish_mmu as arch_tlb_gather_mmu
> simiilar to how other arch-generic helpers are done to avoid some
> #ifdeffery but otherwise

Minchan,

Andrew wishes me to send one series that combines both series. What =
about
this comment from Mel? It seems you intentionally did not want to alias
them...

BTW: patch 4 should add =E2=80=9C#include <asm/tlb.h>" - I=E2=80=99ll =
add it.=20

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

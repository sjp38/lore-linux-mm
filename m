Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 72AEF6B012C
	for <linux-mm@kvack.org>; Tue, 26 May 2015 06:58:04 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so88342531pdb.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 03:58:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id px1si20347416pbb.240.2015.05.26.03.58.03
        for <linux-mm@kvack.org>;
        Tue, 26 May 2015 03:58:03 -0700 (PDT)
Message-ID: <556451B6.6080303@arm.com>
Date: Tue, 26 May 2015 11:57:58 +0100
From: Marc Zyngier <marc.zyngier@arm.com>
MIME-Version: 1.0
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
References: <20150524193404.GD16910@cbox> <20150525141525.GB26958@redhat.com> <20150526080848.GA27075@cbox>
In-Reply-To: <20150526080848.GA27075@cbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "ebru.akagunduz@gmail.com" <ebru.akagunduz@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, Will Deacon <Will.Deacon@arm.com>, Andre Przywara <Andre.Przywara@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 26/05/15 09:08, Christoffer Dall wrote:

[...]

>> Then push the system into swap with some memhog -r1000 xG.
> 
> what is memhog?  I couldn't find the utility in Google...

This looks to be part of the numactl suite, though Debian doesn't seem
to include it in its numactl package...

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

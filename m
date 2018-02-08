Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0B076B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 15:17:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k14so3241855wrc.14
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 12:17:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s128si436347wmf.75.2018.02.08.12.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 12:17:52 -0800 (PST)
Date: Thu, 8 Feb 2018 12:17:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Message-Id: <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
In-Reply-To: <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
	<1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
	<20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
	<87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:

> >
> > So I don't think that the above test result means that errors are properly
> > handled, and the proposed patch should help for arm64.
> 
> Although, the deviation of pud_huge() avoids a kernel crash the code
> would be easier to maintain and reason about if arm64 helpers are
> consistent with expectations by core code.
> 
> I'll look to update the arm64 helpers once this patch gets merged. But
> it would be helpful if there was a clear expression of semantics for
> pud_huge() for various cases. Is there any version that can be used as
> reference?

Is that an ack or tested-by?

Mike keeps plaintively asking the powerpc developers to take a look,
but they remain steadfastly in hiding.

Folks, this patch fixes a BUG and is marked for -stable.  Can we please
prioritize it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

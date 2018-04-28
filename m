Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7875E6B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 05:02:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i131so1694991wmf.6
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 02:02:26 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 34-v6si3257777edm.8.2018.04.28.02.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Apr 2018 02:02:20 -0700 (PDT)
Date: Sat, 28 Apr 2018 11:02:17 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180428090217.n2l3w4vobmtkvz6k@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org>
 <1524764948.2693.478.camel@hpe.com>
 <20180426200737.GS15462@8bytes.org>
 <1524781764.2693.503.camel@hpe.com>
 <20180427073719.GT15462@8bytes.org>
 <1524839460.2693.531.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524839460.2693.531.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Apr 27, 2018 at 02:31:51PM +0000, Kani, Toshi wrote:
> So, we can add the step 2 on top of this patch.
>  1. Clear pud/pmd entry.
>  2. System wide TLB flush <-- TO BE ADDED BY NEW PATCH
>  3. Free its underlining pmd/pte page.

This still lacks the page-table synchronization and will thus not fix
the BUG_ON being triggered.

> We do not need to revert this patch.  We can make the above change I
> mentioned.

Please note that we are not in the merge window anymore and that any fix
needs to be simple and obviously correct.


Thanks,

	Joerg

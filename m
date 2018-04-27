Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5D1D6B0006
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 07:46:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c56-v6so1077924wrc.5
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 04:46:21 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id a88-v6si1580280edf.189.2018.04.27.04.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 04:46:20 -0700 (PDT)
Date: Fri, 27 Apr 2018 13:46:19 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180427114619.GV15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org>
 <1524764948.2693.478.camel@hpe.com>
 <20180426200737.GS15462@8bytes.org>
 <1524781764.2693.503.camel@hpe.com>
 <20180427073719.GT15462@8bytes.org>
 <20180427113923.GF17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427113923.GF17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Apr 27, 2018 at 01:39:23PM +0200, Michal Hocko wrote:
> On Fri 27-04-18 09:37:20, joro@8bytes.org wrote:
> [...]
> > So until we make the generic ioremap code in lib/ioremap.c smarter about
> > unmapping/remapping ranges the best solution is making my fix work again
> > by reverting your patch.
> 
> Could you reuse the same mmu_gather mechanism as we use in the
> zap_*_range?

Yeah, maybe, I havn't looked into the details yet. At least something
similar is needed.


	Joerg

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F96B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:07:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56-v6so27663825wrc.5
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:07:40 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id c34si1930640eda.167.2018.04.26.13.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 13:07:38 -0700 (PDT)
Date: Thu, 26 Apr 2018 22:07:37 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180426200737.GS15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org>
 <1524764948.2693.478.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524764948.2693.478.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Apr 26, 2018 at 05:49:58PM +0000, Kani, Toshi wrote:
> On Thu, 2018-04-26 at 19:23 +0200, joro@8bytes.org wrote:
> > So the PMD entry you clear can still be in a page-walk cache and this
> > needs to be flushed too before you can free the PTE page. Otherwise
> > page-walks might still go to the page you just freed. That is especially
> > bad when the page is already reallocated and filled with other data.
> 
> I do not understand why we need to flush processor caches here. x86
> processor caches are coherent with MESI.  So, clearing an PMD entry
> modifies a cache entry on the processor associated with the address,
> which in turn invalidates all stale cache entries on other processors.

A page walk cache is not about the processors data cache, its a cache
similar to the TLB to speed up page-walks by caching intermediate
results of previous page walks.


Thanks,

	Joerg

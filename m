Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 807376B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 13:15:35 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w204-v6so8389210oib.9
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 10:15:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h126-v6si2820969oia.217.2018.07.05.10.15.34
        for <linux-mm@kvack.org>;
        Thu, 05 Jul 2018 10:15:34 -0700 (PDT)
Date: Thu, 5 Jul 2018 18:16:13 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with addr
Message-ID: <20180705171612.GB25425@arm.com>
References: <20180627141348.21777-1-toshi.kani@hpe.com>
 <20180627141348.21777-3-toshi.kani@hpe.com>
 <20180627155632.GH30631@arm.com>
 <1530115885.14039.295.camel@hpe.com>
 <20180629122358.GC17859@arm.com>
 <1530287995.14039.361.camel@hpe.com>
 <alpine.DEB.2.21.1807032301140.1816@nanos.tec.linutronix.de>
 <20180704173605.GB9668@arm.com>
 <alpine.DEB.2.21.1807042137330.28271@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807042137330.28271@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 04, 2018 at 09:39:50PM +0200, Thomas Gleixner wrote:
> On Wed, 4 Jul 2018, Will Deacon wrote:
> > On Tue, Jul 03, 2018 at 11:02:15PM +0200, Thomas Gleixner wrote:
> > 
> > > I just pick it up and provide Will a branch to pull that lot from.
> > 
> > Thanks, Thomas. Please let me know once you've pushed something out.
> 
> Just pushed it out into tip x86/mm branch. It's based on -rc3 and you can
> consume it up to
> 
>   5e0fb5df2ee8 ("x86/mm: Add TLB purge to free pmd/pte page interfaces")
> 
> Please wait until tomorrow morning so the 0day robot can chew on it. If
> nothing breaks, then it should be good to pull from.

Great, thanks Thomas. It looks like the bot's happy with that, so I've
pulled it locally and I'll push it out as part of the arm64 for-next/core
branch tomorrow, after some basic tests.

Will

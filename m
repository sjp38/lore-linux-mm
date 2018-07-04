Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6AD6B0003
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 15:40:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w21-v6so2738730wmc.4
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 12:40:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i95-v6si3367546wri.413.2018.07.04.12.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jul 2018 12:40:05 -0700 (PDT)
Date: Wed, 4 Jul 2018 21:39:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with
 addr
In-Reply-To: <20180704173605.GB9668@arm.com>
Message-ID: <alpine.DEB.2.21.1807042137330.28271@nanos.tec.linutronix.de>
References: <20180627141348.21777-1-toshi.kani@hpe.com> <20180627141348.21777-3-toshi.kani@hpe.com> <20180627155632.GH30631@arm.com> <1530115885.14039.295.camel@hpe.com> <20180629122358.GC17859@arm.com> <1530287995.14039.361.camel@hpe.com>
 <alpine.DEB.2.21.1807032301140.1816@nanos.tec.linutronix.de> <20180704173605.GB9668@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, 4 Jul 2018, Will Deacon wrote:
> On Tue, Jul 03, 2018 at 11:02:15PM +0200, Thomas Gleixner wrote:
> 
> > I just pick it up and provide Will a branch to pull that lot from.
> 
> Thanks, Thomas. Please let me know once you've pushed something out.

Just pushed it out into tip x86/mm branch. It's based on -rc3 and you can
consume it up to

  5e0fb5df2ee8 ("x86/mm: Add TLB purge to free pmd/pte page interfaces")

Please wait until tomorrow morning so the 0day robot can chew on it. If
nothing breaks, then it should be good to pull from.

Thanks,

	tglx

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C77176B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:31:17 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so15541622pdb.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:31:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id pu10si30591347pdb.124.2015.03.17.10.31.16
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 10:31:17 -0700 (PDT)
Date: Tue, 17 Mar 2015 17:31:11 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/6] make memtest a generic kernel feature
Message-ID: <20150317173111.GA8399@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
 <20150317171822.GW8399@arm.com>
 <5508625F.6060600@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5508625F.6060600@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <Vladimir.Murzin@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, Mark Rutland <Mark.Rutland@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "baruch@tkos.co.il" <baruch@tkos.co.il>, "rdunlap@infradead.org" <rdunlap@infradead.org>

On Tue, Mar 17, 2015 at 05:20:31PM +0000, Vladimir Murzin wrote:
> On 17/03/15 17:18, Will Deacon wrote:
> > On Mon, Mar 09, 2015 at 10:27:04AM +0000, Vladimir Murzin wrote:
> >> Memtest is a simple feature which fills the memory with a given set of
> >> patterns and validates memory contents, if bad memory regions is detected it
> >> reserves them via memblock API. Since memblock API is widely used by other
> >> architectures this feature can be enabled outside of x86 world.
> >>
> >> This patch set promotes memtest to live under generic mm umbrella and enables
> >> memtest feature for arm/arm64.
> >>
> >> It was reported that this patch set was useful for tracking down an issue with
> >> some errant DMA on an arm64 platform.
> >>
> >> Since it touches x86 and mm bits it'd be great to get ACK/NAK for these bits.
> > 
> > Is your intention for akpm to merge this? I don't mind how it goes upstream,
> > but that seems like a sensible route to me.
> > 
> 
> It is already in -mm tree.

Cracking, I missed the memo somehow.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

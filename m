Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E81946B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:37:07 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so11007414pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:37:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z14si8598626pdi.58.2015.08.12.02.37.07
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 02:37:07 -0700 (PDT)
Date: Wed, 12 Aug 2015 10:37:02 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic
 kasan_populate_zero_shadow()
Message-ID: <20150812093701.GH22485@arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
 <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
 <55CA21E8.2060704@gmail.com>
 <20150811164010.GJ23307@e104818-lin.cambridge.arm.com>
 <CAPAsAGwDNpRBLAvyCSpR9ZO9tAmHx-XYjVDZPECeQkU0WOw5jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGwDNpRBLAvyCSpR9ZO9tAmHx-XYjVDZPECeQkU0WOw5jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Aug 12, 2015 at 10:30:37AM +0100, Andrey Ryabinin wrote:
> 2015-08-11 19:40 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> >
> > Not sure how you plan to merge it though since there are x86
> > dependencies. I could send the whole series via tip or the mm tree (and
> > I guess it's pretty late for 4.3).
> 
> Via mm tree, I guess.
> If this is too late for 4.3, then I'll update changelog and send v6
> after 4.3-rc1 release.

That's probably the best bet, as I suspect we'll get some non-trivial
conflicts with the arm64 tree at this stage.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

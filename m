Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5756B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:24:34 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so35957957pab.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 04:24:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hk2si3281339pbb.131.2015.08.13.04.24.33
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 04:24:33 -0700 (PDT)
Date: Thu, 13 Aug 2015 12:24:28 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/2] x86/KASAN updates for 4.3
Message-ID: <20150813112428.GG10280@arm.com>
References: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
 <20150813065040.GA17983@gmail.com>
 <20150813081641.GA14402@gmail.com>
 <20150813090119.GA10280@arm.com>
 <CAPAsAGxk2+v5VG77cOHAThsXyWx-_UJ1XVeJProaa0gQWH5jvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxk2+v5VG77cOHAThsXyWx-_UJ1XVeJProaa0gQWH5jvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, Aug 13, 2015 at 12:02:26PM +0100, Andrey Ryabinin wrote:
> 2015-08-13 12:01 GMT+03:00 Will Deacon <will.deacon@arm.com>:
> > Yes please, works for me! If we're targetting 4.3, then please can you base
> > on 4.2-rc4, as that's what our current arm64 queue is using?
> >
> 
> Does this mean that we are targeting arm64 part for 4.3 too?

It depends on how well it merges with our current queue and whether it
holds up to regression testing. The patches have been reviewed, so I'm
comfortable with the content, but we're not at a stage where we can debug
and fix any failures that might crop up from the merge.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

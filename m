Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BAFAE6B00A3
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 04:50:56 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so11244503pdi.31
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 01:50:56 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id gq2si14839950pbc.217.2014.11.03.01.50.54
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 01:50:55 -0800 (PST)
Date: Mon, 3 Nov 2014 09:50:51 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC V6 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <20141103095051.GA23019@arm.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18274@CNBJMBX05.corpusers.net>
 <20141031104305.GC6731@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18287@CNBJMBX05.corpusers.net>
 <CAKv+Gu-+fe9Hj-uGQHq8KR_6WjrQL-1q=xVBSXVXg2EJO=MW2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-+fe9Hj-uGQHq8KR_6WjrQL-1q=xVBSXVXg2EJO=MW2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joe Perches <joe@perches.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Nov 03, 2014 at 08:47:32AM +0000, Ard Biesheuvel wrote:
> On 3 November 2014 03:17, Wang, Yalin <Yalin.Wang@sonymobile.com> wrote:
> >> From: Will Deacon [mailto:will.deacon@arm.com]
> >> > +#ifndef __ASM_ARM64_BITREV_H
> >> > +#define __ASM_ARM64_BITREV_H
> >>
> >> Really minor nit, but we don't tend to include 'ARM64' in our header guards,
> >> so this should just be __ASM_BITREV_H.
> >>
> >> With that change,
> >>
> >>   Acked-by: Will Deacon <will.deacon@arm.com>
> >>
> > I have send the patch to the patch system:
> > http://www.arm.linux.org.uk/developer/patches/search.php?uid=4025
> >
> > 8187/1 8188/1 8189/1
> >
> > Just remind you that , should also cherry-pick Joe Perches's
> > 2 patches:
> > [PATCH] 6fire: Convert byte_rev_table uses to bitrev8
> > [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
> >
> > To make sure there is no build error when build these 2 drivers.
> >
> 
> If this is the case, I suggest you update patch 8187/1 to retain the
> byte_rev_table symbol, even in the accelerated case, and remove it
> with a followup patch once Joe's patches have landed upstream. Also, a
> link to the patches would be nice, and perhaps a bit of explanation
> how/when they are expected to be merged.

Indeed, or instead put together a series with the appropriate acks so
somebody can merge it all in one go. Merging this on a piecemeal basis is
going to cause breakages (as you pointed out).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

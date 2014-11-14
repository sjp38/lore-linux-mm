Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 239356B00E0
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:26:49 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id x19so17008062ier.16
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:26:48 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0196.hostedemail.com. [216.40.44.196])
        by mx.google.com with ESMTP id bg1si39402958icb.41.2014.11.13.17.26.47
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 17:26:48 -0800 (PST)
Message-ID: <1415928394.4141.3.camel@perches.com>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
From: Joe Perches <joe@perches.com>
Date: Thu, 13 Nov 2014 17:26:34 -0800
In-Reply-To: <20141114011832.GE4042@n2100.arm.linux.org.uk>
References: <20141030120127.GC32589@arm.com>
	 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
	 <20141030135749.GE32589@arm.com>
	 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
	 <20141113235322.GC4042@n2100.arm.linux.org.uk>
	 <1415923530.4223.17.camel@perches.com>
	 <20141114001720.GD4042@n2100.arm.linux.org.uk>
	 <1415925943.4141.1.camel@perches.com>
	 <20141114011832.GE4042@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Takashi Iwai <tiwai@suse.de>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, 2014-11-14 at 01:18 +0000, Russell King - ARM Linux wrote:
> On Thu, Nov 13, 2014 at 04:45:43PM -0800, Joe Perches wrote:
> > I think you shouldn't apply these patches or updated
> > ones either until all the current uses are converted.
> 
> Where are the dependencies mentioned?

I mentioned it when these patches (which are not
mine btw), were submitted the second time.

https://lkml.org/lkml/2014/10/27/69

> How do I get to know when all
> the dependencies are met?

No idea.

> Who is tracking the dependencies?

Not me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

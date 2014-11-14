Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 11FBE6B00D2
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 19:17:39 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so18302754wgg.16
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 16:17:38 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id pn10si46836551wjb.77.2014.11.13.16.17.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 16:17:38 -0800 (PST)
Date: Fri, 14 Nov 2014 00:17:21 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20141114001720.GD4042@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <1415923530.4223.17.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415923530.4223.17.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Takashi Iwai <tiwai@suse.de>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Thu, Nov 13, 2014 at 04:05:30PM -0800, Joe Perches wrote:
> On Thu, 2014-11-13 at 23:53 +0000, Russell King - ARM Linux wrote:
> > On Fri, Oct 31, 2014 at 01:42:44PM +0800, Wang, Yalin wrote:
> > > This patch add bitrev.h file to support rbit instruction,
> > > so that we can do bitrev operation by hardware.
> > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > ---
> > >  arch/arm/Kconfig              |  1 +
> > >  arch/arm/include/asm/bitrev.h | 21 +++++++++++++++++++++
> > >  2 files changed, 22 insertions(+)
> > >  create mode 100644 arch/arm/include/asm/bitrev.h
> > > 
> > > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> > > index 89c4b5c..be92b3b 100644
> > > --- a/arch/arm/Kconfig
> > > +++ b/arch/arm/Kconfig
> > > @@ -28,6 +28,7 @@ config ARM
> > >  	select HANDLE_DOMAIN_IRQ
> > >  	select HARDIRQS_SW_RESEND
> > >  	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
> > > +	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
> > 
> > Looking at this, this is just wrong.  Take a moment to consider what
> > happens if we build a kernel which supports both ARMv6 _and_ ARMv7 CPUs.
> > What happens if an ARMv6 CPU tries to execute an rbit instruction?
> > 
> > Second point (which isn't obvious from your submissions on-list) is that
> > you've loaded the patch system up with patches for other parts of the
> > kernel tree for which I am not responsible for.  As such, I can't take
> > those patches without the sub-tree maintainer acking them.  Also, the
> > commit text in those patches look weird:
> > 
> > 6fire: Convert byte_rev_table uses to bitrev8
> > 
> > Use the inline function instead of directly indexing the array.
> > 
> > This allows some architectures with hardware instructions for bit
> > reversals to eliminate the array.
> > 
> > Signed-off-by: Joe Perches <(address hidden)>
> > Signed-off-by: Yalin Wang <(address hidden)>
> > 
> > Why is Joe signing off on these patches?
> > Shouldn't his entry be an Acked-by: ?
> 
> I didn't sign off on or ack the "add bitrev.h" patch.

Correct, I never said you did.  Please read my message a bit more carefully
next time, huh?

> I created 2 patches that converted direct uses of byte_rev_table
> to that bitrev8 static inline.  One of them is already in -next
> 
> 7a1283d8f5298437a454ec477384dcd9f9f88bac carl9170: Convert byte_rev_table uses to bitrev8
> 
> The other hasn't been applied.
> 
> https://lkml.org/lkml/2014/10/28/1056
> 
> Maybe Takashi Iwai will get around to it one day.

Great, so I can just discard these that were incorrectly submitted to me
then.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

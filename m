Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C8A916B00EA
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 04:52:23 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so895902wgh.9
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 01:52:23 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id fl5si3000083wib.10.2014.11.14.01.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 01:52:22 -0800 (PST)
Date: Fri, 14 Nov 2014 09:52:06 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20141114095205.GF4042@n2100.arm.linux.org.uk>
References: <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <1415923530.4223.17.camel@perches.com>
 <20141114001720.GD4042@n2100.arm.linux.org.uk>
 <1415925943.4141.1.camel@perches.com>
 <20141114011832.GE4042@n2100.arm.linux.org.uk>
 <1415928394.4141.3.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415928394.4141.3.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Takashi Iwai <tiwai@suse.de>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Thu, Nov 13, 2014 at 05:26:34PM -0800, Joe Perches wrote:
> On Fri, 2014-11-14 at 01:18 +0000, Russell King - ARM Linux wrote:
> > On Thu, Nov 13, 2014 at 04:45:43PM -0800, Joe Perches wrote:
> > > I think you shouldn't apply these patches or updated
> > > ones either until all the current uses are converted.
> > 
> > Where are the dependencies mentioned?
> 
> I mentioned it when these patches (which are not
> mine btw), were submitted the second time.

Yes, I'm well aware that the author of the ARM patches are Yalin Wang.

> https://lkml.org/lkml/2014/10/27/69
> 
> > How do I get to know when all
> > the dependencies are met?
> 
> No idea.
> 
> > Who is tracking the dependencies?
> 
> Not me.

Right, what that means is that no one is doing that.  What you've also
said in this thread now is that the ARM patches should not be applied
until all the other users are converted.  As those patches are going via
other trees, that means the ARM patches can only be applied _after_ the
next merge window _if_ all maintainers pick up the previous set.

As I'm not tracking the status of what other maintainers do, I'm simply
going to avoid applying these patches until after the next merge window
and hope that the other maintainers pick the dependent patches up and get
them in during the next merge window.  If not, I guess we'll see compile
breakage.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 99FEF6B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 06:11:05 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so1532023wiv.5
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 03:11:05 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id dg2si3278085wib.98.2015.01.09.03.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 03:11:04 -0800 (PST)
Date: Fri, 9 Jan 2015 11:10:48 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20150109111048.GE12302@n2100.arm.linux.org.uk>
References: <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
 <20141114095812.GG4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E688B313C6@CNBJMBX05.corpusers.net>
 <20150108184059.GZ12302@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103EDAF89E195@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103EDAF89E195@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, Jan 09, 2015 at 10:16:32AM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> > Sent: Friday, January 09, 2015 2:41 AM
> > To: Wang, Yalin
> > Cc: 'Will Deacon'; 'Ard Biesheuvel'; 'linux-kernel@vger.kernel.org';
> > 'akinobu.mita@gmail.com'; 'linux-mm@kvack.org'; 'Joe Perches'; 'linux-arm-
> > kernel@lists.infradead.org'
> > Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
> > 
> > The root cause is that the kernel being built is supposed to support both
> > ARMv7 and ARMv6K CPUs.  However, "rbit" is only available on
> > ARMv6T2 (thumb2) and ARMv7, and not plain ARMv6 or ARMv6K CPUs.
> > 
> In the patch that you applied:
> 8205/1 	add bitrev.h file to support rbit instruction
> 
> I have add :
> +	select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6)
> 
> If you build kernel support ARMv6K, should CONFIG_CPU_V6=y, isn't it ?
> Then will not build hardware rbit instruction, isn't it ?

The config has:

CONFIG_CPU_PJ4=y
# CONFIG_CPU_V6 is not set
CONFIG_CPU_V6K=y
CONFIG_CPU_V7=y
CONFIG_CPU_32v6=y
CONFIG_CPU_32v6K=y
CONFIG_CPU_32v7=y

And no, the CONFIG_CPU_V* flags refer to the CPUs.  The
CONFIG_CPU_32v* symbols refer to the CPU architectures.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

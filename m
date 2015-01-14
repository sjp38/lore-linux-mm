Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 241266B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 11:38:18 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hz20so9094253lab.6
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:38:17 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id cx2si27044861wib.101.2015.01.14.08.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 08:38:16 -0800 (PST)
Date: Wed, 14 Jan 2015 16:38:00 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20150114163800.GZ12302@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
 <20141114095812.GG4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E688B313C6@CNBJMBX05.corpusers.net>
 <20150108184059.GZ12302@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103EDAF89E195@CNBJMBX05.corpusers.net>
 <20150109111048.GE12302@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103EDAF89E198@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <35FD53F367049845BC99AC72306C23D103EDAF89E198@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, Jan 09, 2015 at 08:40:56PM +0800, Wang, Yalin wrote:
> Oh, I see,
> How about change like this:
> +	select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6 && !CPU_V6K)
> I am not sure if I also need add some older CPU types like !CPU_ARM9TDMI &&a??!CPU_ARM940T ?
> 
> Another solution is:
> +	select HAVE_ARCH_BITREVERSE if ((CPU_32V7M || CPU_32V7) && !CPU_32V6 && !CPU_32V5 && !CPU_32V4 && !CPU_32V4T && !CPU_32V3)
> 
> By the way, I am not clear about the difference between CPU_V6 and CPU_V6K, could you tell me? :)

I think

	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6

is sufficient - we don't support mixing pre-v6 and v6+ CPU architectures
into a single kernel.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

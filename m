Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D46526B003D
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 05:31:01 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id cc10so2121028wib.4
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:30:59 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id r5si17803745wjz.159.2014.09.15.02.30.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 02:30:42 -0700 (PDT)
Date: Mon, 15 Sep 2014 10:30:14 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <20140915093014.GZ12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net> <20140915084616.GX12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

On Mon, Sep 15, 2014 at 05:07:53PM +0800, Wang, Yalin wrote:
> Hi
> 
> I tested it on my phone,
> >From log:
> <4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
> <4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000
> 
> <4>[    0.579474] free_initrd_mem: free pfn:8192---8752
> 
> The tail address is not aligned for most initrd image,
> This page will not be freed and lost .

Right, so from this I can assume that you only tested it by seeing what
the addresses were, and the values used in free_initrd_mem().

What you haven't tested is whether the initrd actually gets used with
your changes, which is more what I was interested in given what I found
when reading your patch.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

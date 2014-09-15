Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id A88D56B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:17:03 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id t60so3729258wes.25
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:17:03 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id q20si465546wiv.13.2014.09.15.03.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:16:52 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:16:32 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <20140915101632.GA12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net> <20140915084616.GX12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net> <20140915093014.GZ12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

On Mon, Sep 15, 2014 at 05:59:27PM +0800, Wang, Yalin wrote:
> Hi
> 
> Add more log:
> <4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
> <4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000
> <4>[    0.574868] free_initrd: free initrd 0xc2000000+0xc222fb0e
> <4>[    0.579398] free_initrd_mem: free pfn:8192---8752
> 
> The inird used memory is still the same as the one passed by bootloads,
> I don't change it. It should be safe.

This tells me nothing about whether the initrd is actually /used/.  What
it tells me is that it's being freed.  The function of an initrd is not
to be a chunk of memory which gets freed later on in the boot process.
It is there to provide an "initial ramdisk" (whether it be a filesystem
image, or a CPIO compressed archive) for userspace to run.

So, have you checked that initrd is still functional after this patch?

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

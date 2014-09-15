Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 753B96B003C
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:30:43 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id em10so3874559wid.12
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:30:41 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id lv9si13723510wic.23.2014.09.15.03.30.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:30:34 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:30:13 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <20140915103013.GB12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net> <20140915084616.GX12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net> <20140915093014.GZ12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net> <20140915101632.GA12361@n2100.arm.linux.org.uk> <35FD53F367049845BC99AC72306C23D103D6DB491606@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491606@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

On Mon, Sep 15, 2014 at 06:22:12PM +0800, Wang, Yalin wrote:
> Oh, I see your meaning,
> Yeah , my initrd is a cpio image,
> And it can still work after apply this patch.

Okay, that's what I wanted to know.  However, I believe your patch to
be incorrect.  You delete the assignments to initrd_start and initrd_end
in arm_memblock_init(), which will result in non-OF platforms having
no initrd.

The reason is that OF platforms set initrd_start and initrd_size from
the OF code (drivers/of/fdt.c), but ATAG platforms only set our private
phys_* versions.

The reason I went with phys_* stuff was to permit better verification
of the addresses passed - that the addresses were indeed memory locations
before passing them through something like __va().

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

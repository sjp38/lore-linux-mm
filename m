Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CFCDD6B0039
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:58:24 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so6037817pde.12
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:58:24 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id jj4si22057548pbb.226.2014.09.15.03.58.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:58:23 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 18:58:15 +0800
Subject: RE: [RFC] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491608@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net>
 <20140915084616.GX12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
 <20140915093014.GZ12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net>
 <20140915101632.GA12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491606@CNBJMBX05.corpusers.net>
 <20140915103013.GB12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140915103013.GB12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

Oh, I see,
I don't consider non-of platform kernels,
I will send V2 patch for this .

Thanks

-----Original Message-----
From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]=20
Sent: Monday, September 15, 2014 6:30 PM
To: Wang, Yalin
Cc: 'Will Deacon'; 'linux-kernel@vger.kernel.org'; 'linux-arm-kernel@lists.=
infradead.org'; 'linux-mm@kvack.org'; linux-arm-msm@vger.kernel.org
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page ali=
gned

On Mon, Sep 15, 2014 at 06:22:12PM +0800, Wang, Yalin wrote:
> Oh, I see your meaning,
> Yeah , my initrd is a cpio image,
> And it can still work after apply this patch.

Okay, that's what I wanted to know.  However, I believe your patch to be in=
correct.  You delete the assignments to initrd_start and initrd_end in arm_=
memblock_init(), which will result in non-OF platforms having no initrd.

The reason is that OF platforms set initrd_start and initrd_size from the O=
F code (drivers/of/fdt.c), but ATAG platforms only set our private
phys_* versions.

The reason I went with phys_* stuff was to permit better verification of th=
e addresses passed - that the addresses were indeed memory locations before=
 passing them through something like __va().

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up accor=
ding to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

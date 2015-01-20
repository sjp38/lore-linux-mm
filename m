Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id EE5E56B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:51:00 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id p9so10652565lbv.4
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:51:00 -0800 (PST)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id zl8si15438429lbb.27.2015.01.20.06.50.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 06:50:59 -0800 (PST)
Received: by mail-la0-f50.google.com with SMTP id pn19so34621241lab.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:50:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150120140546.DDCB8D4@black.fi.intel.com>
References: <54BD33DC.40200@ti.com>
	<20150119174317.GK20386@saruman>
	<20150120001643.7D15AA8@black.fi.intel.com>
	<20150120114555.GA11502@n2100.arm.linux.org.uk>
	<20150120140546.DDCB8D4@black.fi.intel.com>
Date: Tue, 20 Jan 2015 12:50:59 -0200
Message-ID: <CAOMZO5D-Z-FLPmQ4Yy3rxBa-FebLcnG9TSzg3F-MF-TFBBMrwQ@mail.gmail.com>
Subject: Re: [next-20150119]regression (mm)?
From: Fabio Estevam <festevam@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Nishanth Menon <nm@ti.com>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-omap <linux-omap@vger.kernel.org>

On Tue, Jan 20, 2015 at 12:05 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Russell King - ARM Linux wrote:
>> On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
>> > Better option would be converting 2-lvl ARM configuration to
>> > <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
>>
>> Well, IMHO the folded approach in asm-generic was done the wrong way
>> which barred ARM from ever using it.
>
> Okay, I see.
>
> Regarding the topic bug. Completely untested patch is below. Could anybody
> check if it helps?

Yes, it helps. Now I can boot mx6 running linux-next 20150120 with
your patch applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

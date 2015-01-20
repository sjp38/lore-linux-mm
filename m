Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C490B6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:08:23 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id z10so3769384pdj.13
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:08:23 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hw8si4531324pbc.148.2015.01.20.06.08.20
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 06:08:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150120114555.GA11502@n2100.arm.linux.org.uk>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
Subject: Re: [next-20150119]regression (mm)?
Content-Transfer-Encoding: 7bit
Message-Id: <20150120140546.DDCB8D4@black.fi.intel.com>
Date: Tue, 20 Jan 2015 16:05:46 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Felipe Balbi <balbi@ti.com>, Nishanth Menon <nm@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Russell King - ARM Linux wrote:
> On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
> > Better option would be converting 2-lvl ARM configuration to
> > <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
> 
> Well, IMHO the folded approach in asm-generic was done the wrong way
> which barred ARM from ever using it.

Okay, I see.

Regarding the topic bug. Completely untested patch is below. Could anybody
check if it helps?

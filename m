Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C82A6B0005
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 16:06:15 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id q25-v6so3735747wmq.9
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 13:06:15 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s6-v6si10376124wru.343.2018.11.04.13.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 04 Nov 2018 13:06:13 -0800 (PST)
Date: Sun, 4 Nov 2018 22:05:56 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] x86/build: Build VSMP support only if CONFIG_PCI is
 selected
In-Reply-To: <2130cd90-2c8f-2fc4-0ac8-81a5aea153b2@scalemp.com>
Message-ID: <alpine.DEB.2.21.1811042202530.10744@nanos.tec.linutronix.de>
References: <2130cd90-2c8f-2fc4-0ac8-81a5aea153b2@scalemp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eial Czerwacki <eial@scalemp.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Randy Dunlap <rdunlap@infradead.org>, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>, Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, X86 ML <x86@kernel.org>, Oren Twaig <oren@scalemp.com>

Eial,

On Thu, 1 Nov 2018, Eial Czerwacki wrote:

> Subject: x86/build: Build VSMP support only if CONFIG_PCI is selected

That's not what the patch does, right?

> vsmp dependency on pv_irq_ops removed some years ago, so now let's clean
> it up from vsmp_64.c.
> 
> In short, "cap & ctl & (1 << 4)" was always returning 0, as such we can
> remove all the PARAVIRT/PARAVIRT_XXL code handling that.
> 
> However, the rest of the code depends on CONFIG_PCI, so fix it accordingly.
> in addition, rename set_vsmp_pv_ops to set_vsmp_ctl.
> 
> Signed-off-by: Eial Czerwacki <eial@scalemp.com>
> Acked-by: Shai Fultheim <shai@scalemp.com>

Unfortunately that patch does not apply. It's white space damaged, i.e. all
tabs are converted to spaces.

Thanks,

	tglx

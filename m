Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9656B000C
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 03:13:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s141-v6so872652pgs.23
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 00:13:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r68-v6si35997181pfk.151.2018.11.02.00.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 00:13:11 -0700 (PDT)
Subject: Re: [PATCH v2] x86/build: Build VSMP support only if CONFIG_PCI is
 selected
References: <2130cd90-2c8f-2fc4-0ac8-81a5aea153b2@scalemp.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <2073effd-4f02-c784-ca71-69ba49f51b88@suse.com>
Date: Fri, 2 Nov 2018 08:13:07 +0100
MIME-Version: 1.0
In-Reply-To: <2130cd90-2c8f-2fc4-0ac8-81a5aea153b2@scalemp.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eial Czerwacki <eial@scalemp.com>, LKML <linux-kernel@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>, Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, X86 ML <x86@kernel.org>, Oren Twaig <oren@scalemp.com>

On 01/11/2018 19:27, Eial Czerwacki wrote:
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

While I'm still thinking selection of HYPERVISOR_GUEST and PARAVIRT
is a little bit strange, you can add:

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

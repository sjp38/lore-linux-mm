Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E288B6B000A
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 09:10:48 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id w131-v6so3134679oie.4
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 06:10:48 -0700 (PDT)
Received: from scalemp.com (www.scalemp.com. [169.44.78.149])
        by mx.google.com with ESMTPS id z3-v6si4180134oig.92.2018.11.01.06.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 06:10:47 -0700 (PDT)
Subject: Re: [PATCH] x86/build: Build VSMP support only if selected
References: <20181030230905.xHZmM%akpm@linux-foundation.org>
 <9e14d183-55a4-8299-7a18-0404e50bf004@infradead.org>
 <alpine.DEB.2.21.1811011032190.1642@nanos.tec.linutronix.de>
 <SN6PR15MB2366D7688B41535AF0A331F9C3CE0@SN6PR15MB2366.namprd15.prod.outlook.com>
From: Eial Czerwacki <eial@scalemp.com>
Message-ID: <a8f2ac8e-45dc-1c12-e888-6ad880b1306f@scalemp.com>
Date: Thu, 1 Nov 2018 15:10:35 +0200
MIME-Version: 1.0
In-Reply-To: <SN6PR15MB2366D7688B41535AF0A331F9C3CE0@SN6PR15MB2366.namprd15.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>
Cc: "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>, Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, X86 ML <x86@kernel.org>, 'Oren Twaig' <oren@scalemp.com>

Greetings,

On 11/01/2018 12:39 PM, Shai Fultheim (Shai@ScaleMP.com) wrote:
> On 01/11/18 11:37, Thomas Gleixner wrote:
> 
>> VSMP support is built even if CONFIG_X86_VSMP is not set. This leads to a build
>> breakage when CONFIG_PCI is disabled as well.
>>
>> Build VSMP code only when selected.
> 
> This patch disables detect_vsmp_box() on systems without CONFIG_X86_VSMP, due to
> the recent 6da63eb241a05b0e676d68975e793c0521387141.  This is significant
> regression that will affect significant number of deployments.
> 
> We will reply shortly with an updated patch that fix the dependency on pv_irq_ops,
> and revert to CONFIG_PARAVIRT, with proper protection for CONFIG_PCI.
> 

here is the proper patch which fixes the issue on hand:

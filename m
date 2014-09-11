Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 418EF6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:32:27 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so6985297pdb.0
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:32:26 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rh9si30525067pdb.147.2014.09.10.22.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 10 Sep 2014 22:32:25 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBQ00K2326OHW50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 11 Sep 2014 06:35:12 +0100 (BST)
Message-id: <5411325A.5010308@samsung.com>
Date: Thu, 11 Sep 2014 09:25:46 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
 <5410724B.8000803@intel.com>
 <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com>
 <5410D486.4060200@intel.com> <9E98939B-E2C6-4530-A822-ED550FC3B9D2@zytor.com>
 <54112512.6040409@oracle.com> <54112607.9030303@zytor.com>
 <20140911044650.GN4120@two.firstfloor.org>
In-reply-to: <20140911044650.GN4120@two.firstfloor.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 09/11/2014 08:46 AM, Andi Kleen wrote:
> On Wed, Sep 10, 2014 at 09:33:11PM -0700, H. Peter Anvin wrote:
>> On 09/10/2014 09:29 PM, Sasha Levin wrote:
>>> On 09/11/2014 12:26 AM, H. Peter Anvin wrote:
>>>> Except you just broke PVop kernels.
>>>
>>> So is this why v2 refuses to boot on my KVM guest? (was digging
>>> into that before I send a mail out).
>>>
>>
>> No, KVM should be fine.  It is Xen PV which ends up as a smoldering crater.
> 
> Just exclude it in Kconfig? I assume PV will eventually go away anyways.
> 
> -Andi
> 

That's done already in this patch:

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -135,6 +135,7 @@ config X86
 	select HAVE_ACPI_APEI if ACPI
 	select HAVE_ACPI_APEI_NMI if ACPI
 	select ACPI_LEGACY_TABLES_LOOKUP if ACPI
+	select HAVE_ARCH_KASAN if X86_64 && !XEN

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

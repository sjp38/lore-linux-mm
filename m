Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 943866B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:52:36 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7888833pab.15
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:52:36 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id fn9si27768040pdb.160.2014.09.10.21.52.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 21:52:35 -0700 (PDT)
Message-ID: <54112A7B.7060400@zytor.com>
Date: Wed, 10 Sep 2014 21:52:11 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com> <5410724B.8000803@intel.com> <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com> <5410D486.4060200@intel.com> <9E98939B-E2C6-4530-A822-ED550FC3B9D2@zytor.com> <54112512.6040409@oracle.com> <54112607.9030303@zytor.com> <20140911044650.GN4120@two.firstfloor.org>
In-Reply-To: <20140911044650.GN4120@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 09/10/2014 09:46 PM, Andi Kleen wrote:
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

That would be nice...

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

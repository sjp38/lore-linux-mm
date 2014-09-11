Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EE7D86B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:27:08 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8419598pab.32
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:27:08 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id cw5si30292840pbc.133.2014.09.10.21.27.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 21:27:07 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
From: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <5410D486.4060200@intel.com>
Date: Wed, 10 Sep 2014 21:26:46 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <9E98939B-E2C6-4530-A822-ED550FC3B9D2@zytor.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com> <5410724B.8000803@intel.com> <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com> <5410D486.4060200@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

Except you just broke PVop kernels.

Sent from my tablet, pardon any formatting problems.

> On Sep 10, 2014, at 15:45, Dave Hansen <dave.hansen@intel.com> wrote:
> 
>> On 09/10/2014 01:30 PM, Andrey Ryabinin wrote:
>> Yes, there is a reason for this. For inline instrumentation we need to
>> catch access to userspace without any additional check.
>> This means that we need shadow of 1 << 61 bytes and we don't have so
>> many addresses available.
> 
> That sounds reasonable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

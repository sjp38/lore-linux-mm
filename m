Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id DEB6C6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:46:53 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ge10so4986313lab.40
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:46:53 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id q3si23640229lbj.123.2014.09.10.21.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 21:46:52 -0700 (PDT)
Date: Thu, 11 Sep 2014 06:46:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
Message-ID: <20140911044650.GN4120@two.firstfloor.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
 <5410724B.8000803@intel.com>
 <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com>
 <5410D486.4060200@intel.com>
 <9E98939B-E2C6-4530-A822-ED550FC3B9D2@zytor.com>
 <54112512.6040409@oracle.com>
 <54112607.9030303@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54112607.9030303@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On Wed, Sep 10, 2014 at 09:33:11PM -0700, H. Peter Anvin wrote:
> On 09/10/2014 09:29 PM, Sasha Levin wrote:
> > On 09/11/2014 12:26 AM, H. Peter Anvin wrote:
> >> Except you just broke PVop kernels.
> > 
> > So is this why v2 refuses to boot on my KVM guest? (was digging
> > into that before I send a mail out).
> > 
> 
> No, KVM should be fine.  It is Xen PV which ends up as a smoldering crater.

Just exclude it in Kconfig? I assume PV will eventually go away anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

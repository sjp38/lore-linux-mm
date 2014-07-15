Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E24846B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:00:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so193734pad.0
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 17:00:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id kr7si13007621pab.13.2014.07.15.17.00.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 17:00:11 -0700 (PDT)
Message-ID: <53C5C066.2060707@zytor.com>
Date: Tue, 15 Jul 2014 16:59:34 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle
 WT type
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <1405452884-25688-4-git-send-email-toshi.kani@hp.com> <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com> <1405465801.28702.34.camel@misato.fc.hp.com> <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com> <53C5BD3E.2010600@zytor.com> <CALCETrUV2NseM8u6YqQ3trqLy+10_A6sd7nmfkgO3Rnw3GSxiQ@mail.gmail.com>
In-Reply-To: <CALCETrUV2NseM8u6YqQ3trqLy+10_A6sd7nmfkgO3Rnw3GSxiQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On 07/15/2014 04:54 PM, Andy Lutomirski wrote:
> 
> From vague memory, the current mechanism for tracking RAM memtypes (as
> opposed to memtypes for everything that isn't RAM) is limited to a
> very small number of types, leading to oddities like not being able to
> create WT ram with this patchset.
> 
> Using the pagetables directly would be simpler (no extra data
> structure) and would automatically exactly track the set of memtypes
> that can fit in the pagetable structures.
> 

I don't think there is anything fundamental, though.  The number of
types had more to do with what there was demand for.  I will look into it.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E3E5F6B00A9
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:50:39 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ik5so2714862vcb.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:50:39 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id kl5si7451021vdb.26.2014.09.10.13.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:50:39 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id le20so5198136vcb.13
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:50:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140910204724.GA11363@redhat.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-11-git-send-email-a.ryabinin@samsung.com>
	<20140910203814.GA10244@redhat.com>
	<CAPAsAGxwPZ_Qn_4d8hGcjcz1ZSN5-2qqqjqJhDPmv7NKq9=x+Q@mail.gmail.com>
	<20140910204724.GA11363@redhat.com>
Date: Thu, 11 Sep 2014 00:50:39 +0400
Message-ID: <CAPAsAGxPHZw0o=Z7620rCPvhbWpymSRhUg7DaUgZcff=3dC9JA@mail.gmail.com>
Subject: Re: [RFC/PATCH v2 10/10] lib: add kasan test module
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-09-11 0:47 GMT+04:00 Dave Jones <davej@redhat.com>:
> On Thu, Sep 11, 2014 at 12:46:04AM +0400, Andrey Ryabinin wrote:
>  > 2014-09-11 0:38 GMT+04:00 Dave Jones <davej@redhat.com>:
>  > > On Wed, Sep 10, 2014 at 06:31:27PM +0400, Andrey Ryabinin wrote:
>  > >  > This is a test module doing varios nasty things like
>  > >  > out of bounds accesses, use after free. It is usefull for testing
>  > >  > kernel debugging features like kernel address sanitizer.
>  > >
>  > >  > +void __init kmalloc_oob_rigth(void)
>  > >  > +{
>  > >
>  > > 'right' ?
>  > >
>  > >
>  >
>  > I mean to the right side here (opposite to left), not synonym of  word
>  > 'correct'.
>
> yes, but there's a typo.
>
>         Dave

Yeah, I see now, thanks.

-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

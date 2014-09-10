Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id E9D896B00A7
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:47:55 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so9921366qgd.15
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:47:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i2si20049616qcd.30.2014.09.10.13.47.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 13:47:55 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:47:24 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC/PATCH v2 10/10] lib: add kasan test module
Message-ID: <20140910204724.GA11363@redhat.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-11-git-send-email-a.ryabinin@samsung.com>
 <20140910203814.GA10244@redhat.com>
 <CAPAsAGxwPZ_Qn_4d8hGcjcz1ZSN5-2qqqjqJhDPmv7NKq9=x+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxwPZ_Qn_4d8hGcjcz1ZSN5-2qqqjqJhDPmv7NKq9=x+Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Sep 11, 2014 at 12:46:04AM +0400, Andrey Ryabinin wrote:
 > 2014-09-11 0:38 GMT+04:00 Dave Jones <davej@redhat.com>:
 > > On Wed, Sep 10, 2014 at 06:31:27PM +0400, Andrey Ryabinin wrote:
 > >  > This is a test module doing varios nasty things like
 > >  > out of bounds accesses, use after free. It is usefull for testing
 > >  > kernel debugging features like kernel address sanitizer.
 > >
 > >  > +void __init kmalloc_oob_rigth(void)
 > >  > +{
 > >
 > > 'right' ?
 > >
 > >
 > 
 > I mean to the right side here (opposite to left), not synonym of  word
 > 'correct'.

yes, but there's a typo.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2C76B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:46:02 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c80so18229263iod.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:46:02 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id m82si2274142itm.10.2017.01.25.08.46.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 08:46:01 -0800 (PST)
Date: Wed, 25 Jan 2017 10:45:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
In-Reply-To: <20170123004657.GT5238@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1701251045040.983@east.gentwo.org>
References: <20170118110731.GA15949@linux.vnet.ibm.com> <20170118111201.GB29472@bombadil.infradead.org> <20170118221737.GP5238@linux.vnet.ibm.com> <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org> <20170123004657.GT5238@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Sun, 22 Jan 2017, Paul E. McKenney wrote:

> On Wed, Jan 18, 2017 at 06:00:24PM -0600, Christoph Lameter wrote:
> > On Wed, 18 Jan 2017, Paul E. McKenney wrote:
> >
> > > Actually, slab is using RCU to provide type safety to those slab users
> > > who request it.
> >
> > Typesafety is a side effect. The main idea here is that the object can
> > still be accessed in RCU sections after another processor frees the
> > object. We guarantee that the object is not freed but it may be reused
> > for another object within the RCU period.
> >
> > Can we have a name that expresses all of that properly?
>
> But of course!!!  "Type safety".  http://wiki.c2.com/?TypeSafe

Well that does not convey the idea that RCU is involved here.

SLAB_DESTROY_RCU_TYPESAFE

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

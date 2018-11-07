Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4B856B0575
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:00:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id n5-v6so17314902plp.16
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 15:00:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j193si1879788pge.332.2018.11.07.15.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 15:00:55 -0800 (PST)
Date: Wed, 7 Nov 2018 15:00:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: encode object length in the handle
Message-Id: <20181107150052.ed3d26414c3b2f74956a3d42@linux-foundation.org>
In-Reply-To: <CAMJBoFMWV-HbymH6D0PYF6EJFoLoheDHCwaQgZiadvd7BZSE2w@mail.gmail.com>
References: <20181025112821.0924423fb9ecc7918896ec2b@gmail.com>
	<20181025124249.0ba63f1041ed8836ff6e6190@linux-foundation.org>
	<CAMJBoFMWV-HbymH6D0PYF6EJFoLoheDHCwaQgZiadvd7BZSE2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleksiy.Avramchenko@sony.com, Guenter Roeck <linux@roeck-us.net>

On Mon, 29 Oct 2018 13:27:36 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> Hi Andrew,
> 
> Den tors 25 okt. 2018 kl 21:42 skrev Andrew Morton <
> akpm@linux-foundation.org>:
> 
> > On Thu, 25 Oct 2018 11:28:21 +0200 Vitaly Wool <vitalywool@gmail.com>
> > wrote:
> >
> > > Reclaim and free can race on an object (which is basically ok) but
> > > in order for reclaim to be able to  map "freed" object we need to
> > > encode object length in the handle. handle_to_chunks() is thus
> > > introduced to extract object length from a handle and use it during
> > > mapping of the last object we couldn't correctly map before.
> >
> > What are the runtime effects of this change?
> >
> 
> I haven't observed any adverse impact with this change used in zswap (and
> in fact, this is a bugfix for zswap operation). There is a slight under 1%
> impact when z3fold is used with ZRAM but since the support for ZRAM over
> zpool is still out of tree, I take it doesn't matter at this point, right?
> 

I mean "runtime effects", not "run time effects" ;)

Apart from wishing to document this change fully, I'm trying to
understand which kernel version(s) need the fix.  To understand that, I
need to know the effect upon end-user-visible behaviour.  You say it
fixes a bug - please describe that bug: how it is triggered, what
effect is has, etc.

Also, any suggestions as to which kernel versions we should fix is
always welcome.

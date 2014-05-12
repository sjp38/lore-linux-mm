Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEFF6B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 16:36:56 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so70364pbc.9
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:36:56 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id bn5si6887089pbb.65.2014.05.12.13.36.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 13:36:55 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so9325239pab.15
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:36:55 -0700 (PDT)
Date: Mon, 12 May 2014 13:36:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: randconfig build error with next-20140512, in mm/slub.c
In-Reply-To: <537118C6.7050203@iki.fi>
Message-ID: <alpine.DEB.2.02.1405121336180.961@chino.kir.corp.google.com>
References: <CA+r1Zhg4JzViQt=J0XBu4dRwFUZGwi52QLefkzwcwn4NUfk8Sw@mail.gmail.com> <alpine.DEB.2.10.1405121346370.30318@gentwo.org> <537118C6.7050203@iki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Christoph Lameter <cl@linux.com>, Jim Davis <jim.epost@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, 12 May 2014, Pekka Enberg wrote:

> On 05/12/2014 09:47 PM, Christoph Lameter wrote:
> > A patch was posted today for this issue.
> 
> AFAICT, it's coming from -mm. Andrew, can you pick up the fix?
> 
> > Date: Mon, 12 May 2014 09:36:30 -0300
> > From: Fabio Estevam <fabio.estevam@freescale.com>
> > To: akpm@linux-foundation.org
> > Cc: linux-mm@kvack.org, festevam@gmail.com, Fabio Estevam
> > <fabio.estevam@freescale.com>,    Christoph Lameter <cl@linux.com>, David
> > Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>
> > Subject: [PATCH] mm: slub: Place count_partial() outside CONFIG_SLUB_DEBUG
> > if block
> > 

That's the wrong fix since it doesn't work properly when sysfs is 
disabled.  We want http://marc.info/?l=linux-mm-commits&m=139992385527040 
which was merged into -mm already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

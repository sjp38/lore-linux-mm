Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8589882F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:21:14 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so131736096pab.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:21:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rs7si32204176pab.188.2015.10.16.15.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:21:13 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:21:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-Id: <20151016152112.c2faec391b2b16580860a772@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
	<517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
	<20151016131726.GA602@node.shutemov.name>
	<20151016135106.GJ11309@esperanza>
	<alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 16 Oct 2015 15:12:23 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -26,6 +26,7 @@
> > >  #include <linux/page_counter.h>
> > >  #include <linux/vmpressure.h>
> > >  #include <linux/eventfd.h>
> > > +#include <linux/mm.h>
> > >  #include <linux/mmzone.h>
> > >  #include <linux/writeback.h>
> > >  
> 
> Are you expecting to use mem_cgroup_from_kmem() from other places
> in future?  Seems possible; but at present it's called from only
> one place, and (given how memcontrol.h has somehow managed to avoid
> including mm.h all these years), I thought it would be nice to avoid
> it for just this;

Yes, I was wondering about that.  I figured that anything which
includes memcontrol.h is already including mm.h and gcc is pretty
efficient with handling the #ifdef FOO_H_INCLUDED guards.

> and fixed my build with the patch below last night.
> Whatever you all think best: just wanted to point out an alternative.

Yes, that's neater - let's go that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

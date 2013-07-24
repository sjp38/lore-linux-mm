Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E2BB76B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:15:19 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id es20so595244lab.19
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:15:17 -0700 (PDT)
Date: Wed, 24 Jul 2013 22:15:16 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130724181516.GI8508@moon>
References: <20130724160826.GD24851@moon>
 <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon>
 <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon>
 <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 10:42:24AM -0700, Andy Lutomirski wrote:
> >
> > Lets just be clear about the problem first: the vmscan pass referred to
> > above happens only on clean pages, so the soft dirty bit could only be
> > set if the page was previously dirty and got written back.  Now it's an
> > exercise for the reader whether we want to reinstantiate a cleaned
> > evicted page for the purpose of doing an iterative migration or whether
> > we want to flip the page in the migrated entity to be evicted (so if it
> > gets referred to, it pulls in an up to date copy) ... assuming the
> > backing file also gets transferred, of course.

Good question! I rather forward it to Pavel as an author for soft dirty
bit feature. Pavel?

> I think I understand your distinction.  Nonetheless, given the loss of
> the soft-dirty bit, the migration tool could fail to notice that the
> pages was dirtied and subsequently cleaned and evicted.  I'm
> unconvinced that doing this on a per-PTE basis is the right way,
> though.

I fear for tracking soft-dirty-bit for swapped entries we sinply have
no other place than pte (still i'm quite open for ideas, maybe there
are a better way which I've missed).

> I've long wanted a feature to efficiently see what changed on a
> filesystem by comparing, say, a hash tree.  NTFS can do this (sort
> of), but I don't think that anything else can.  I think that btrfs
> should be able to, but there's no API that I've ever seen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

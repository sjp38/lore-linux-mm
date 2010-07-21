Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7A64B6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 13:37:26 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6433bf44-2a68-485a-b048-a7aca241677d@default>
Date: Wed, 21 Jul 2010 10:37:20 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
 <4f986c65-c17e-47d8-9c30-60cd17809cbb@default> <4C45A9BA.1090903@vflare.org>
 <9e4cae1f-c102-43ea-9ba0-611c8ad68c9b@default 4C46772E.3000500@vflare.org>
In-Reply-To: <4C46772E.3000500@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > Maybe the best solution is to make the threshold a sysfs
> > settable?  Or maybe BOTH the single-page threshold and
> > the average threshold as two different sysfs settables?
> > E.g. throw away a put page if either it compresses poorly
> > or adding it to the pool would push the average over.
>=20
> Considering overall compression average instead of bothering about
> individual page compressibility seems like a good point. Still, I think
> storing completely incompressible pages isn't desirable.
>=20
> So, I agree with the idea of separate sysfs tunables for average and
> single-page
> compression thresholds with defaults conservatively set to 50% and
> PAGE_SIZE/2
> respectively. I will include these in "v2" patches.

Unless the single-page compression threshold is higher than the
average, the average is useless.  IMHO I'd suggest at least
5*PAGE_SIZE/8 as the single-page threshold, possibly higher.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

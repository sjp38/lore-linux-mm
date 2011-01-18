Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 154816B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:57:19 -0500 (EST)
MIME-Version: 1.0
Message-ID: <9e7aa896-ed1f-4d50-8227-3a922be39949@default>
Date: Tue, 18 Jan 2011 09:53:58 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org
 20110110131626.GA18407@shutemov.name>
In-Reply-To: <20110110131626.GA18407@shutemov.name>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Monday, January 10, 2011 6:16 AM
> To: Nitin Gupta
> Cc: Pekka Enberg; Hugh Dickins; Andrew Morton; Greg KH; Dan
> Magenheimer; Rik van Riel; Avi Kivity; Christoph Hellwig; Minchan Kim;
> Konrad Rzeszutek Wilk; linux-mm; linux-kernel
> Subject: Re: [PATCH 0/8] zcache: page cache compression support
>=20
> Hi,
>=20
> What is status of the patchset?
> Do you have updated patchset with fixes?
>=20
> --
>  Kirill A. Shutemov

I wanted to give Nitin a week to respond, but I guess he
continues to be offline.

I believe zcache is completely superceded by kztmem.
Kztmem, like zcache, is dependent on cleancache
getting merged.

Kztmem may supercede zram also although frontswap (which
kztmem uses for a more dynamic in-memory swap compression)
and zram have some functional differences that support
both being merged.

For latest kztmem patches and description, see:

https://lkml.org/lkml/2011/1/18/170=20


Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

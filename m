Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id DF32F6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 15:20:50 -0500 (EST)
MIME-Version: 1.0
Message-ID: <224b1c8a-2ae0-486b-bfdd-4a161f662afd@default>
Date: Fri, 18 Jan 2013 12:19:17 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/3] zram: force disksize setting before using zram
References: <1358388769-30112-1-git-send-email-minchan@kernel.org>
 <20130118004219.GB29380@kroah.com>
In-Reply-To: <20130118004219.GB29380@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jerome Marchand <jmarchan@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>

> From: Greg Kroah-Hartman [mailto:gregkh@linuxfoundation.org]
> Sent: Thursday, January 17, 2013 5:42 PM
> To: Minchan Kim
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Nitin Gupta; Seth J=
ennings; Dan Magenheimer;
> Konrad Rzeszutek Wilk; Jerome Marchand; Pekka Enberg
> Subject: Re: [PATCH 1/3] zram: force disksize setting before using zram
>=20
> On Thu, Jan 17, 2013 at 11:12:47AM +0900, Minchan Kim wrote:
> > Now zram document syas "set disksize is optional"
> > but partly it's wrong. When you try to use zram firstly after
> > booting, you must set disksize, otherwise zram can't work because
> > zram gendisk's size is 0. But once you do it, you can use zram freely
> > after reset because reset doesn't reset to zero paradoxically.
> > So in this time, disksize setting is optional.:(
> > It's inconsitent for user behavior and not straightforward.
> >
> > This patch forces always setting disksize firstly before using zram.
> > Yes. It changes current behavior so someone could complain when
> > he upgrades zram. Apparently it could be a problem if zram is mainline
> > but it still lives in staging so behavior could be changed for right
> > way to go. Let them excuse.
>=20
> I don't know about changing this behavior.  I need some acks from some
> of the other zram developers before I can take this, or any of the other
> patches in this series.

I'm not officially a zram developer, but I have used it and I
am knowledgeable about in-kernel compression and know the specific
problem being fixed here.  Unless/until compression is much
more tightly integrated into MM policies and "z*" can manage
space more dynamically, Minchan's patch seems to be a good way
to go, especially since zram has found a solid niche in the
embedded (no swap disk) community.  So FWIW:

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

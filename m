Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C5EE86B01B9
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:49:25 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:45:43 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <AANLkTikSzWZme6kioKJ7DJbS0nhYqeDTPas1D9rb_LY-@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006291043070.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <AANLkTikSzWZme6kioKJ7DJbS0nhYqeDTPas1D9rb_LY-@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-535100867-1277826343=:16135"
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-535100867-1277826343=:16135
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 28 Jun 2010, Pekka Enberg wrote:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_KERNEL & gfp_all=
owed_mask);
> > =A0 =A0 =A0 =A0else {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *ptr =3D vmalloc(size);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr)
>
> This looks wrong to me. All slab allocators should do gfp_allowed_mask
> magic under the hood. Maybe it's triggering kmalloc_large() path that
> needs the masking too?

They do gfp_allowed_mask magic. But the checks at function entry of the
slabs do not mask the masks so we get false positives without this. All my
protest against the checks doing it this IMHO broken way were ignored.
---1463811839-535100867-1277826343=:16135--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

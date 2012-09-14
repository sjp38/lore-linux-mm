Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 944726B01F7
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 06:15:44 -0400 (EDT)
From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Date: Fri, 14 Sep 2012 18:15:19 +0800
Subject: RE: [PATCH] nommu: remap_pfn_range: fix addr parameter check
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FB1E6975F@EAPEX1MAIL1.st.com>
References: <1347504057-5612-1-git-send-email-lliubbo@gmail.com>
	<20120913122738.04eaceb3.akpm@linux-foundation.org>
 <CAHG8p1CJ7YizySrocYvQeCye4_63TkAimsAGU1KC5+Fn0wqF8w@mail.gmail.com>
In-Reply-To: <CAHG8p1CJ7YizySrocYvQeCye4_63TkAimsAGU1KC5+Fn0wqF8w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Jiang <scott.jiang.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "laurent.pinchart@ideasonboard.com" <laurent.pinchart@ideasonboard.com>, "uclinux-dist-devel@blackfin.uclinux.org" <uclinux-dist-devel@blackfin.uclinux.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "gerg@uclinux.org" <gerg@uclinux.org>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>

> -----Original Message-----
> From: Scott Jiang [mailto:scott.jiang.linux@gmail.com]
> Sent: Friday, September 14, 2012 2:53 PM
> To: Andrew Morton
> Cc: Bob Liu; linux-mm@kvack.org; Bhupesh SHARMA;
> laurent.pinchart@ideasonboard.com; uclinux-dist-
> devel@blackfin.uclinux.org; linux-media@vger.kernel.org;
> dhowells@redhat.com; geert@linux-m68k.org; gerg@uclinux.org;
> stable@kernel.org; gregkh@linuxfoundation.org; Hugh Dickins
> Subject: Re: [PATCH] nommu: remap_pfn_range: fix addr parameter check
>=20
> > Yes, the MMU version of remap_pfn_range() does permit non-page-
> aligned
> > `addr' (at least, if the userspace maaping is a non-COW one).  But I
> > suspect that was an implementation accident - it is a nonsensical
> > thing to do, isn't it?  The MMU cannot map a bunch of kernel pages
> > onto a non-page-aligned userspace address.
> >
> > So I'm thinking that we should declare ((addr & ~PAGE_MASK) !=3D 0) to
> > be a caller bug, and fix up this regrettably unidentified v4l driver?
>=20
> I agree. This should be fixed in videobuf.
>=20
> Hi sharma, what's your kernel version? It seems videobuf2 already fixed t=
his
> bug in 3.5.

Hi Scott,

I was using 3.3 linux kernel. I will again check if videobuf2 in 3.5 has al=
ready fixed this issue.

Regards,
Bhupesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

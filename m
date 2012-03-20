Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 562FF6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 10:09:03 -0400 (EDT)
Date: Tue, 20 Mar 2012 09:08:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/6] kenrel.h: add ALIGN_OF_LAST_BIT()
In-Reply-To: <CACVxJT_UVRjkSK+kieYVpO4R+D-4S2bXaoK-apxMkuFAYsgi_A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1203200908330.19333@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-2-git-send-email-laijs@cn.fujitsu.com> <op.wbgvn00x3l0zgt@mpn-glaptop> <CACVxJT_UVRjkSK+kieYVpO4R+D-4S2bXaoK-apxMkuFAYsgi_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1987152897-1332252541=:19333"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1987152897-1332252541=:19333
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 20 Mar 2012, Alexey Dobriyan wrote:

> >> +#define ALIGN_OF_LAST_BIT(x) =C2=A0 ((((x)^((x) - 1))>>1) + 1)
> >
> >
> > Wouldn't ALIGNMENT() be less confusing? After all, that's what this mac=
ro is
> > calculating, right? Alignment of given address.
>
> Bits do not have alignment because they aren't directly addressable.
> Can you hardcode this sequence with comment, because it looks too
> special for macro.

Some sane naming please. This is confusing.

---1463811839-1987152897-1332252541=:19333--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

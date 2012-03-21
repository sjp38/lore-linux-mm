Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B6A0A6B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 01:14:06 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1064377vcb.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 22:14:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F6944D9.5090002@cn.fujitsu.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
	<1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
	<20120320154619.GA5684@google.com>
	<4F6944D9.5090002@cn.fujitsu.com>
Date: Tue, 20 Mar 2012 22:14:05 -0700
Message-ID: <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
Subject: Re: [RFC PATCH 6/6] workqueue: use kmalloc_align() instead of hacking
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Tue, Mar 20, 2012 at 8:02 PM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote=
:
> Yes, I don't want to build a complex kmalloc_align(). But after I found
> that SLAB/SLUB's kmalloc-objects are natural/automatic aligned to
> a proper big power of two. I will do nothing if I introduce kmalloc_align=
()
> except just care the debugging.
>
> o =A0 =A0 =A0 SLAB/SLUB's kmalloc-objects are natural/automatic aligned.
> o =A0 =A0 =A0 70LOC in total, and about 90% are just renaming or wrapping=
.
>
> I think it is a worth trade-off, it give us convenience and we pay
> zero overhead(when runtime) and 70LOC(when coding, pay in a lump sum).
>
> And kmalloc_align() can be used in the following case:
> o =A0 =A0 =A0 a type object need to be aligned with cache-line for it con=
tains a frequent
> =A0 =A0 =A0 =A0update-part and a frequent read-part.
> o =A0 =A0 =A0 The total number of these objects in a given type is not mu=
ch, creating
> =A0 =A0 =A0 =A0a new slab cache for a given type will be overkill.
>
> This is a RFC patch and it seems mm gurus don't like it. I'm sorry I both=
er all of you.

Ooh, don't be sorry. My only concern is that it doesn't have any user
other than cwq allocation. If you can find other cases which can
benefit from it, it would be great.

Thanks.

--=20
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

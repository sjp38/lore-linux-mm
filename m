Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AEA6D8D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 04:01:46 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so1320351gwa.14
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 01:01:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110317070705.15100.qmail@science.horizon.com>
References: <AANLkTikDAEuTcrgo0YcUO40A9x5jaL-d+ZPviCXANe3r@mail.gmail.com>
	<20110317070705.15100.qmail@science.horizon.com>
Date: Thu, 17 Mar 2011 10:01:44 +0200
Message-ID: <AANLkTinsiWXHtrU0aN1Fsavs-2M2VD=vRYLjNhLQiO0s@mail.gmail.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi, rientjes@google.com, Christoph Lameter <cl@linux-foundation.org>

On Thu, Mar 17, 2011 at 9:07 AM, George Spelvin <linux@horizon.com> wrote:
>> I certainly don't but I'd still like to ask you to change it to
>> 'unsigned long'. That's a Linux kernel idiom and we're not going to
>> change the whole kernel.
>
> Damn, and I just prepared the following patch. =A0Should I, instead, do
>
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -62,5 +62,5 @@ struct kmem_cache {
> =A0/* 3) touched by every alloc & free from the backend */
>
> - =A0 =A0 =A0 unsigned int flags; =A0 =A0 =A0 =A0 =A0 =A0 /* constant fla=
gs */
> + =A0 =A0 =A0 unsigned long flags; =A0 =A0 =A0 =A0 =A0 =A0/* constant fla=
gs */
> =A0 =A0 =A0 =A0unsigned int num; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* # of objs=
 per slab */
>
> ... because the original slab code uses an unsigned int.

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

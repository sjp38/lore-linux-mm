Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E90896B00A4
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 22:46:47 -0500 (EST)
Received: by iyj17 with SMTP id 17so12708909iyj.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 19:46:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E1PZXeb-0004AV-2b@tytso-glaptop>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
Date: Mon, 3 Jan 2011 12:46:45 +0900
Message-ID: <AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 3, 2011 at 8:48 AM, Theodore Ts'o <tytso@mit.edu> wrote:
>
> Given the patches being busily submitted by trivial patch submitters to
> make use kmem_cache_zalloc(), et. al, I believe we should remove the
> unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:
>
> - =A0 =A0 =A0 if (unlikely((flags & __GFP_ZERO) && objp))
> + =A0 =A0 =A0 if ((flags & __GFP_ZERO) && objp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(objp, 0, obj_size(cachep));
>
> Agreed? =A0If so, I'll send a patch...

I support it.

Recently Steven tried to gather the information.
http://thread.gmane.org/gmane.linux.kernel/1072767
Maybe he might have a number for that.


>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0- Ted
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

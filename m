Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E06A46B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 18:47:55 -0500 (EST)
From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Date: Thu, 23 Feb 2012 18:47:52 -0500
References: <20120222150010.c784b29b.akpm@linux-foundation.org> <1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
In-Reply-To: <1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart14333366.JjcOP8X6Ki";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201202231847.55733.vapier@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>

--nextPart14333366.JjcOP8X6Ki
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 22 February 2012 23:03:31 Siddhesh Poyarekar wrote:
> With this patch in place, /proc/PID/task/TID/maps are treated as 'maps
> as the task would see it' and hence, only the vma that that task uses
> as stack is marked as [stack]. All other 'stack' vmas are marked as
> anonymous memory. /proc/PID/maps acts as a thread group level view,
> where all stack vmas are marked.

i don't suppose we could have it say "[tid stack]" rather than "[stack]" ? =
 or=20
perhaps even "[stack tid:%u]" with replacing %u with the tid ?
=2Dmike

--nextPart14333366.JjcOP8X6Ki
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPRtArAAoJEEFjO5/oN/WB1uMQAJSUPQQCP7fcPpJaUEMMuaF/
Nw1wSdyAPKXbZskXaZ1Yzzk09kz+i07kktfH6VreSBNsAGS7B0az2DrUr+aS0egg
8aJnWWHoF0rCAzJMulw5mpxDtKpg1kjD9vb/N5RFPq/53G6KB4YmqppYQO1JIL8P
KK+OS86rIsr3EQvOXgZJlbj0rQNdP8HSxL61XvuFcW3UywRu+EVno0eNSwfcyAFd
bsHhKGdBZ9BztiKL41Zw6DhBty71tR4zUR2UjuONJI4e9tIzP/DHri6WhOIr8qyO
HFoQ2UpxEfRVCHAUOc/7aObBHL7Yb46mf2XToIA1r4UM5C/8wt8RREsGEOAcv21i
Exctn/+EuvvNN316APFa3J+67NN4JYotUJ5odWslRNBBsOCzApb3DLiJC/nExXsa
BITw9UGGgVACmO2bdyuTAAtsU+ttVpTcbuhudGYc80H/DJt72JMHH3Bh4nPrssZN
rhXqvswqzBSzrFmDmrxuOyr84q4Lqr+Gx6knRL7XjTUR5lz/yk/GX8iu68MLBTt7
acW4tly8nt5CJAGcY/KL9FBd95FDbZ+TqzzQJG9kVZW3UGU0WkBb0G+B9a/xPnsU
pCZBM4IMuwtO7cP5cTVan40lk+37MyBRALJ7lljiQcB+Abu2mAbiTUcI+oSNzwZL
f2SnnQLPpN/0QWoj18fy
=lVl7
-----END PGP SIGNATURE-----

--nextPart14333366.JjcOP8X6Ki--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

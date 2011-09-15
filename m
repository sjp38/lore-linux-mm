Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 051796B0010
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 01:48:08 -0400 (EDT)
Received: by iaen33 with SMTP id n33so1445447iae.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 22:48:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315357399.31737.49.camel@debian>
References: <1315188460.31737.5.camel@debian>
	<alpine.DEB.2.00.1109061914440.18646@router.home>
	<1315357399.31737.49.camel@debian>
Date: Thu, 15 Sep 2011 08:48:06 +0300
Message-ID: <CAOJsxLFcvWXcXZGWUrwzAE2rA8SmObrWaeg6ZYV8RfDG=nNCiA@mail.gmail.com>
Subject: Re: [PATCH] slub Discard slab page only when node partials > minimum setting
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

On Wed, Sep 7, 2011 at 4:03 AM, Alex,Shi <alex.shi@intel.com> wrote:
> Unfreeze_partials may try to discard slab page, the discarding condition
> should be 'when node partials number > minimum partial number setting',
> not '<' in current code.
>
> This patch base on penberg's tree's 'slub/partial' head.
>
> git://git.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git
>
> Signed-off-by: Alex Shi <alex.shi@intel.com>
>
> ---
> =A0mm/slub.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index b351480..66a5b29 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1954,7 +1954,7 @@ static void unfreeze_partials(struct kmem_cache *s)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new.frozen =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!new.inuse && (!n || n-=
>nr_partial < s->min_partial))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!new.inuse && (!n || n-=
>nr_partial > s->min_partial))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m =3D M_FR=
EE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kme=
m_cache_node *n2 =3D get_node(s,

Can you please resend the patch with Christoph's ACK and a better
explanation why the condition needs to be flipped. A reference to
commit 81107188f123e3c2217ac2f2feb2a1147904c62f ("slub: Fix partial
count comparison confusion") is probably sufficient.

P.S. Please use the penberg@cs.helsinki.fi email address for now.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

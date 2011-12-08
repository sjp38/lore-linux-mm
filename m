Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0039B6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:26:24 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so2322109wgb.26
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:26:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1112072314140.28419@chino.kir.corp.google.com>
References: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com>
	<alpine.DEB.2.00.1112072304010.28419@chino.kir.corp.google.com>
	<CAFPAmTSJDXD1KNVBUz75yN_CeCT9f_+W9CaRNN467LSyCD+WXg@mail.gmail.com>
	<alpine.DEB.2.00.1112072314140.28419@chino.kir.corp.google.com>
Date: Thu, 8 Dec 2011 12:56:22 +0530
Message-ID: <CAFPAmTSKXCiXNnFK0zR651ONju+ZBYE0qWUhCF9GXZRy=ieSJw@mail.gmail.com>
Subject: Re: [PATCH 1/1] vmalloc: purge_fragmented_blocks: Acquire spinlock
 before reading vmap_block
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>
> That's intentional as an optimization, we don't care if
> vb->free + vb->dirty =3D=3D VMAP_BBMAP_BITS && vb->dirty !=3D VMAP_BBMAP_=
BITS
> would speculatively be true after we grab vb->lock, we'll have to purge i=
t
> next time instead. =A0We certainly don't want to grab vb->lock for blocks
> that aren't candidates, so this optimization is a singificant speedup.

Ah, I agree.
Anyway, the probability of there being too many vmap_blocks being
missed due to concurrent changes
is not quite high, so I guess its okay that a few vmap_blocks get
purged next time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

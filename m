Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0F16B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 22:47:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d0584e86-34f6-46cc-a78e-c1e31ed7cb9f@default>
Date: Thu, 4 Aug 2011 19:45:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <20110804075730.GF31039@tiehlicka.suse.cz>
 <20110804090017.GI31039@tiehlicka.suse.cz>
 <876efe5f-7222-4c67-aa3f-0c6e4272f5e1@default
 CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
In-Reply-To: <CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

> > I am fairly sure that the failed allocation is handled gracefully
> > through the remainder of the frontswap code, but will re-audit to
> > confirm. =C2=A0A warning might be nice though.
>=20
> There is a place i think maybe have problem.
> function __frontswap_flush_area() in file frontswap.c called
> memset(sis->frontswap_map, .., ..);
> But if frontswap_map allocation fail there is a null pointer access ?

Good catch!

I'll fix that when I submit a frontswap update in a few days.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

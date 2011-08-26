Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2606B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 10:16:09 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <24f09c1f-3ff8-4677-a1f7-c3494ced04c1@default>
Date: Fri, 26 Aug 2011 07:15:30 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure
 changes
References: <20110823145755.GA23174@ca-server1.us.oracle.com>
 <20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
 <8a95a804-7ba3-416e-9ba5-8da7b9cabba5@default
 20110826090214.2f7f2cdc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110826090214.2f7f2cdc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure c=
hanges
>=20
> > > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > > Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structu=
re changes
> >
> > Hi Kamezawa-san --
> >
> > Domo arigato for the review and feedback!
> >
> > > Hmm....could you modify mm/swapfile.c and remove 'static' in the same=
 patch ?
> >
> > I separated out this header patch because I thought it would
> > make the key swap data structure changes more visible.  Are you
> > saying that it is more confusing?
>=20
> Yes. I know you add a new header file which is not included but..
>=20
> At reviewing patch, I check whether all required changes are done.
> In this case, you turned out the function to be externed but you
> leave the function definition as 'static'. This unbalance confues me.
>=20
> I always read patches from 1 to END. When I found an incomplete change
> in patch 1, I remember it and need to find missng part from patch 2->End.
> This makes my review confused a little.
>=20
> In another case, when a patch adds a new file, I check Makefile change.
> Considering dependency, the patch order should be
>=20
> =09[patch 1] Documentaion/Config
> =09[patch 2] Makefile + add new file.
>=20
> But plesse note: This is my thought. Other guys may have other idea.

I think that is probably a good approach.  I will try to use it
for future patches.  But since this frontswap patchset is already
on V7, I hope it is OK if I continue to organize it for V8 the same
as it has been, as it might be confusing to previous reviewers
to change the organization now.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0ECAE6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 13:36:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <125abdf8-0af9-447b-8782-68acf1c9c229@default>
Date: Thu, 28 Mar 2013 10:35:52 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: remove swapcache page early
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <433aaa17-7547-4e39-b472-7060ee15e85f@default>
 <alpine.LNX.2.00.1303271541200.30535@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303271541200.30535@eggly.anvils>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

> From: Hugh Dickins [mailto:hughd@google.com]
> Subject: RE: [RFC] mm: remove swapcache page early
>=20
> On Wed, 27 Mar 2013, Dan Magenheimer wrote:
> > > From: Hugh Dickins [mailto:hughd@google.com]
> > > Subject: Re: [RFC] mm: remove swapcache page early
> > >
> > The issue you are raising
> > here is (2).  You may not know that (2) has recently been solved
> > in frontswap, at least for zcache.  See frontswap_exclusive_gets_enable=
d.
> > If this is enabled (and it is for zcache but not yet for zswap),
> > what you suggest (SetPageDirty) is what happens.
>=20
> Ah, and I have a dim, perhaps mistaken, memory that I gave you
> input on that before, suggesting the SetPageDirty.  Good, sounds
> like the solution is already in place, if not actually activated.
>=20
> Thanks, must dash,
> Hugh

Hi Hugh --

Credit where it is due...  Yes, I do recall now that the idea
was originally yours.  It went on a to-do list where I eventually
tried it and it worked... I'm sorry I had forgotten and neglected
to give you credit!

(BTW, it is activated for zcache in 3.9.)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

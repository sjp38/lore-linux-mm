Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 262286B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 04:56:47 -0500 (EST)
Date: Thu, 10 Dec 2009 09:56:36 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: An mm bug in today's 2.6.32 git tree
In-Reply-To: <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0912100951130.31654@sister.anvils>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
 <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
 <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1357647399-1260438996=:31654"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1357647399-1260438996=:31654
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 10 Dec 2009, Am=C3=A9rico Wang wrote:
> On Wed, Dec 9, 2009 at 10:49 PM, Hugh Dickins
> >
> > Thanks for the report. =C2=A0Not known to me.
> > It looks like something has corrupted the start of a pagetable.
                                  no, not the start
> > No idea what that something might be, but probably not bad RAM.
> >
> >>
> >> Please feel free to let me know if you need more info.
> >
> > You say you saw it twice: please post what the other occasion
> > showed (unless the first six lines were identical to this and it
> > occurred around the same time i.e. separate report of the same).
> >
>=20
> Yes, the rest are almost the same, the only difference is the 'addr'
> shows different addresses.

Please post what this other occasion showed, if you still have the log.

Hugh
--8323584-1357647399-1260438996=:31654--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

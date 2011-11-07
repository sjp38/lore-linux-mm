Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B2FBE6B0070
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 09:35:43 -0500 (EST)
MIME-Version: 1.0
Message-ID: <e3566bd4-bf52-4e75-87bd-d42debcc07b6@default>
Date: Mon, 7 Nov 2011 06:35:27 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (SUMMARY)
References: <20111104164532.GO18879@redhat.com>
 <d19dddac-0713-47bf-bec7-04cc8d534b50@default
 CAOJsxLFXy7-u+G_MLUnD3+kYqxsbns4dQV2WEpBu2oCJ4PtT7A@mail.gmail.com>
In-Reply-To: <CAOJsxLFXy7-u+G_MLUnD3+kYqxsbns4dQV2WEpBu2oCJ4PtT7A@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> From: Pekka Enberg [mailto:penberg@kernel.org]
> Subject: Re: [GIT PULL] mm: frontswap (SUMMARY)
>=20
> On Sun, Nov 6, 2011 at 9:31 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > A farewell haiku:
> >
> > Crash test dummy folds.
> > KVM mafia wins.
> > Innovation cries.
>=20
> Does this mean you've stopped working on frontswap or that frontswap
> is dead? What does this mean for the cleancache hooks? Are they still
> useful?

Wow.  F***ing incredible.

Pekka, you'd best leave the politics to Andrea.  He's
_much_ better at it.

No, I haven't stopped, though I may be pausing to lick
my wounds.  No it's not dead yet.  Yes, the cleancache
hooks are still useful, so narrow-minded anti-Xen
vultures can go circle elsewhere.

Since my attempt at gracefully ending the discussion
with poetry has been ruined, I might as well spell it out:

"Crash test dummy folds":  (1) Andrew, I'm warning you
(from the first crash test dummy) that the new process
may be too heavy handed and corruptible.  (2) I've taken
enough beatings for now, thank you.

"KVM mafia wins" :  If one reads between the many
(far too many) lines of this discussion, and as further
evidenced by Pekka's reply, the anti-Xen crowd has
been losing too many battles recently, is damn
well not going to lose this one, and would like
by any means possible to reverse previous losses.
People, can't we just get along?

"Innovation cries":  I'm expressing sadness that
a very innovative and elegant approach to a very
hard problem, that began Xen-specific but seems
to have lots of interesting uses, is being blocked
for political reasons.  I'm not denying that there
is plenty of work still to be done, just arguing
that this can best be explored as a community
project... and that's not going to happen by
conveniently ignoring the most mature user (Xen)
because one has a personal or corporate vendetta
against it.

Frontswap should be in-tree.  For anyone familiar
with the American political system, frontswap
has been blocked by a filibuster.

I won't be responding to further posts on this
topic for awhile, for health reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

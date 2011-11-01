Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3526B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 18:25:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <82d2f082-6ab1-479e-bbf9-f04992804420@default>
Date: Tue, 1 Nov 2011 15:25:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
 <ef778e79-72d0-4c58-99e8-3b36d85fa30d@default>
 <20111101095038.30289914.kamezawa.hiroyu@jp.fujitsu.com>
 <f62e02cd-fa41-44e8-8090-efe2ef052f64@default
 20111101144309.a51c99b5.akpm@linux-foundation.org>
In-Reply-To: <20111101144309.a51c99b5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Tue, 1 Nov 2011 08:25:38 -0700 (PDT)
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> At kernel summit there was discussion and overall agreement that we've
> been paying insufficient attention to the big-picture "should we
> include this feature at all" issues.  We resolved to look more
> intensely and critically at new features with a view to deciding
> whether their usefulness justified their maintenance burden.  It seems
> that you're our crash-test dummy ;) (Now I'm wondering how to get
> "cgroups: add a task counter subsystem" put through the same wringer).
>=20
> I will confess to and apologise for dropping the ball on cleancache and
> frontswap.  I was never really able to convince myself that it met the
> (very vague) cost/benefit test, but nor was I able to present
> convincing arguments that it failed that test.  So I very badly went
> into hiding, to wait and see what happened.  What we needed all those
> months ago was to have the discussion we're having now.
>=20
> This is a difficult discussion and a difficult decision.  But it is
> important that we get it right.  Thanks for you patience.

Thanks very much for your very kind response.  Let me know if
I can do anything else to help the process other than continuing
the discussion of course.  I'll be happy to help as soon as
I return from the crash-test-dummy hospital ;-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

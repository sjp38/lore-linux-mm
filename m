Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D01886B0196
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 11:58:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <52b5aee3-f424-42ae-830f-d1cf64fa49ef@default>
Date: Thu, 8 Sep 2011 08:50:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 3/4] mm: frontswap: add swap hooks and extend
 try_to_unuse
References: <20110829164929.GA27216@ca-server1.us.oracle.com
 20110907162703.7f8116b9.akpm@linux-foundation.org>
In-Reply-To: <20110907162703.7f8116b9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Wednesday, September 07, 2011 5:27 PM
> To: Dan Magenheimer
> Subject: Re: [PATCH V8 3/4] mm: frontswap: add swap hooks and extend try_=
to_unuse
>=20
> On Mon, 29 Aug 2011 09:49:29 -0700
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > -static int try_to_unuse(unsigned int type)
> > +int try_to_unuse(unsigned int type, bool frontswap,
>=20
> Are patches 2 and 3 in the wrong order?

No, they've applied in that order and built after each patch
properly for well over a year.  At a minimum, frontswap.h must
be created before patch 3of4, though I suppose the introduction
of frontswap.c could be after patch 3of4... Note that frontswap.c
(which calls try_to_unuse()) is non-functional (and isn't even built)
until after patch 4of4 is applied.

There is enough interdependency between the four parts
that perhaps it should all be a single commit.  I split
it up for reviewer's convenience but apparently different
reviewers use different review processes than I anticipated. :-}

Bottom line though: yes, bisecting at any point in the
patchset does work properly.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

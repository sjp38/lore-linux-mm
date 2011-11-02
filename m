Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D99426B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 15:06:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2bc86220-1e48-40e5-b502-dcd093956fd5@default>
Date: Wed, 2 Nov 2011 12:06:02 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default20111101012017.GJ3466@redhat.com>
 <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default20111101180702.GL3466@redhat.com>
 <b8a0ca71-a31b-488a-9a92-2502d4a6e9bf@default
 20111102013122.GA18879@redhat.com>
In-Reply-To: <20111102013122.GA18879@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> Hi Dan.
>=20
> On Tue, Nov 01, 2011 at 02:00:34PM -0700, Dan Magenheimer wrote:
> > Pardon me for complaining about my typing fingers, but it seems
> > like you are making statements and asking questions as if you
> > are not reading the whole reply before you start responding
> > to the first parts.  So it's going to be hard to answer each
> > sub-thread in order.  So let me hit a couple of the high
> > points first.
>=20
> I'm actually reading all your reply, if I skip some part it may be
> because the email is too long already :). I'm just trying to
> understand it and I wish I had more time to dedicate to this too but
> I've other pending stuff too.

Hi Andrea --

First, let me apologize for yesterday.  I was unnecessarily
sarcastic and disrespectful, and I am sorry.  I very much appreciate
your time and discussion, and good hard technical questions
that have allowed me to clarify some of the design and
implementation under discussion.

I agree this email is too long, though it has been very useful.
You've got some great feedback and insights in improving
zcache, so let me be the first to cry "uncle" (surrender)
and cut to the end....

> If you confirm it's free to go and there's no ABI/API we get stuck
> into, I'm fairly positive about it, it's clearly "alpha" feature
> behavior (almost no improvement with zram today) but it could very
> well be in the right direction and give huge benefit compared to zram
> in the future. I definitely don't pretend things to be perfect... but
> they must be in the right design direction for me to be sold off on
> those. Just like KVM in virt space.

Confirmed.  Anything below the "struct frontswap_ops" (and
"struct cleancache_ops), that is anything in the staging/zcache
directory, is wide open for your ideas and improvement.
In fact, I would very much welcome your contribution and
I think IBM and Nitin would also.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF22E6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 17:01:30 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1b9107c1-20a3-4e2c-9d83-6449857fb514@default>
Date: Wed, 24 Aug 2011 14:01:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V7 0/4] mm: frontswap: overview (and proposal to merge at
 next window)
References: <20110823145735.GA23160@ca-server1.us.oracle.com
 20110824205355.GD27865@dumpdata.com>
In-Reply-To: <20110824205355.GD27865@dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: Konrad Rzeszutek Wilk
> Subject: Re: [PATCH V7 0/4] mm: frontswap: overview (and proposal to merg=
e at next window)
>=20
> On Tue, Aug 23, 2011 at 07:57:35AM -0700, Dan Magenheimer wrote:
> > [PATCH V7 0/4] mm: frontswap: overview (and proposal to merge at next w=
indow)
>=20
> Is there a git branch of these patches?

I'll get V7 into linux-next in a day or two (assuming someone else
doesn't find a glaring problem before then which would require a V8).
Linux-next currently has V6.
=20
> Also, on a unrelated note - your patches have 'Subject: Subject: [PATCH..=
'
> - you might want to fix your fancy mail sending tools.

Sigh, sorry.  It's an artifact of my use of "git am".  I thought I
had fixed it in my scripts after a trial send to myself, but neglected
to move the changed script to my external-email-sending machine.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

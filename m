Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3D21C9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 15:13:59 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <af23974b-20e8-47fc-8063-e7c1440e46aa@default>
Date: Wed, 21 Sep 2011 12:13:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap
 feedback
References: <20110915213446.GA26406@ca-server1.us.oracle.com
 20110921150232.GB541@phenom.oracle.com>
In-Reply-To: <20110921150232.GB541@phenom.oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Konrad Wilk
>=20
> On Thu, Sep 15, 2011 at 02:34:46PM -0700, Dan Magenheimer wrote:
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap=
 feedback
>=20
> That is a pretty bad title. Think about it - in a year, you are going to
> try to track down something using 'git annotate' and this git commit is g=
oing
> to come up. And you look at it and this is the title. It does not carry
> the technical details of what is in the patch.
>=20
> Also in case you are thinking "But there are so more git commits" - don't
> fret about them. It is OK to have many of them. So don't by shy with them=
.

OK, thanks for the feedback.  Since there are no code changes,
I won't flood the list with another version with the patches divided
differently (and thanks for your help reorganizing them and your offlist
review so I know it meets your approval!); instead I will just make a
new v11 git branch.  Since kernel.org is still down, if anyone
wants to look at the latest, it can be found at:

git://oss.oracle.com/git/djm/tmem.git#frontswap-v11

I'll also be asking Stephen Rothwell to pull v11 into linux-next
because the frontswap version that is there is getting a bit stale.

Hopefully everything is finally now ready for merging for the
3.2 window!

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

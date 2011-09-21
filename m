Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4203D9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 15:15:43 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <80a7cf89-8aae-4db6-bc2b-fa5aa44cf978@default>
Date: Wed, 21 Sep 2011 12:15:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->invalidate
References: <20110915213506.GA26426@ca-server1.us.oracle.com
 20110921150420.GC541@phenom.oracle.com>
In-Reply-To: <20110921150420.GC541@phenom.oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Konrad Rzeszutek Wilk
> Sent: Wednesday, September 21, 2011 9:04 AM
> To: Dan Magenheimer
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; jeremy@goop.org; hu=
ghd@google.com;
> ngupta@vflare.org; Konrad Wilk; JBeulich@novell.com; Kurt Hackel; npiggin=
@kernel.dk; akpm@linux-
> foundation.org; riel@redhat.com; hannes@cmpxchg.org; matthew@wil.cx; Chri=
s Mason;
> sjenning@linux.vnet.ibm.com; kamezawa.hiroyu@jp.fujitsu.com; jackdachef@g=
mail.com;
> cyclonusj@gmail.com; levinsasha928@gmail.com
> Subject: Re: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->inval=
idate
>=20
> On Thu, Sep 15, 2011 at 02:35:06PM -0700, Dan Magenheimer wrote:
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V10 6/6] mm: frontswap/cleancache: final flush->invalid=
ate
>=20
> Just call it 's/flush/invalidate/' change.
> >
> > This sixth patch of six in this frontswap series completes the renaming
> > from "flush" to "invalidate" across both tmem frontends (cleancache and
> > frontswap) and both tmem backends (Xen and zcache), as required by akpm=
.
> > This change is completely cosmetic.
> >
> > [v10: no change]
>=20
> No need for that.. You only need to include them if you did provide some
> new content to the patch.

OK, thanks.  Fixed in v11.  Since no code changes, not reposting,
available in git tree at:=20

git://oss.oracle.com/git/djm/tmem.git#frontswap-v11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

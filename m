Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE729000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:29:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a7471ea9-1d24-452a-8e3b-eb5836e8e7d5@default>
Date: Tue, 20 Sep 2011 11:28:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
References: <20110915213406.GA26369@ca-server1.us.oracle.com
 4E73674B.6090901@linux.vnet.ibm.com>
In-Reply-To: <4E73674B.6090901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Friday, September 16, 2011 9:12 AM
> To: Dan Magenheimer
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; jeremy@goop.org; hu=
ghd@google.com;
> ngupta@vflare.org; Konrad Wilk; JBeulich@novell.com; Kurt Hackel; npiggin=
@kernel.dk; akpm@linux-
> foundation.org; riel@redhat.com; hannes@cmpxchg.org; matthew@wil.cx; Chri=
s Mason;
> kamezawa.hiroyu@jp.fujitsu.com; jackdachef@gmail.com; cyclonusj@gmail.com=
; levinsasha928@gmail.com
> Subject: Re: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
>=20
> On 09/15/2011 04:34 PM, Dan Magenheimer wrote:
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
> >
> > [v10: sjenning@linux.vnet.ibm.com: fix debugfs calls on 32-bit]
> ...
> > +#ifdef CONFIG_DEBUG_FS
> > +=09struct dentry *root =3D debugfs_create_dir("frontswap", NULL);
> > +=09if (root =3D=3D NULL)
> > +=09=09return -ENXIO;
> > +=09debugfs_create_u64("gets", S_IRUGO, root, &frontswap_gets);
> > +=09debugfs_create_u64("succ_puts", S_IRUGO, root, &frontswap_succ_puts=
);
> > +=09debugfs_create_u64("puts", S_IRUGO, root, &frontswap_failed_puts);
>=20
> Sorry I didn't see this one before :-/  This should be "failed_puts",
> not "puts".

Oops, thought I had replied to this but hadn't.

Thanks for catching that typo.  Unless someone reports something
else that needs fixing, I will likely just fix that in my git tree
rather than post a V11.
=20
> Other than that, it compiles cleanly here and runs without issue when
> applied on 3.1-rc4 + fix for cleancache crash.

Thanks for the testing!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

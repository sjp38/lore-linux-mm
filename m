Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 041A06B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:56:31 -0400 (EDT)
Received: from mail164-va3 (localhost [127.0.0.1])	by
 mail164-va3-R.bigfish.com (Postfix) with ESMTP id C55784E0132	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:56:30 +0000 (UTC)
Received: from VA3EHSMHS033.bigfish.com (unknown [10.7.14.240])	by
 mail164-va3.bigfish.com (Postfix) with ESMTP id 24EB04000BD	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:56:28 +0000 (UTC)
Received: from mail198-co9 (localhost [127.0.0.1])	by
 mail198-co9-R.bigfish.com (Postfix) with ESMTP id 37DD1880117	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 23 Jul 2013 16:54:56 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Tue, 23 Jul 2013 16:54:50 +0000
Message-ID: <84917bea4f304a649eaf640f8926f09b@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130723160158.GC27054@kroah.com>
In-Reply-To: <20130723160158.GC27054@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Tuesday, July 23, 2013 12:02 PM
> To: KY Srinivasan
> Cc: linux-kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepf=
le.de;
> apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> mm@kvack.org; kamezawa.hiroyuki@gmail.com; mhocko@suse.cz;
> hannes@cmpxchg.org; yinghan@google.com; jasowang@redhat.com;
> kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On Fri, Jul 19, 2013 at 12:23:05PM -0700, K. Y. Srinivasan wrote:
> > The current machinery for hot-adding memory requires having udev
> > rules to bring the memory segments online. Export the necessary functio=
nality
> > to to bring the memory segment online without involving user space code=
.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/base/memory.c  |    5 ++++-
> >  include/linux/memory.h |    4 ++++
> >  2 files changed, 8 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> > index 2b7813e..a8204ac 100644
> > --- a/drivers/base/memory.c
> > +++ b/drivers/base/memory.c
> > @@ -328,7 +328,7 @@ static int
> __memory_block_change_state_uevent(struct memory_block *mem,
> >  	return ret;
> >  }
> >
> > -static int memory_block_change_state(struct memory_block *mem,
> > +int memory_block_change_state(struct memory_block *mem,
> >  		unsigned long to_state, unsigned long from_state_req,
> >  		int online_type)
> >  {
> > @@ -341,6 +341,8 @@ static int memory_block_change_state(struct
> memory_block *mem,
> >
> >  	return ret;
> >  }
> > +EXPORT_SYMBOL(memory_block_change_state);
>=20
> EXPORT_SYMBOL_GPL() for all of these please.

Will do.
>=20
> And as others have pointed out, I can't export symbols without a user of
> those symbols going into the tree at the same time.  So I'll drop this
> patch for now and wait for your consumer of these symbols to be
> submitted.

I will submit the consumer as well.

Thanks,

K. Y
=20
> greg k-h
>=20
>=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

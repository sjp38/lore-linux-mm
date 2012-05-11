Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 7DF258D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:32:28 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6a2c6de7-fc2f-4af7-9abd-da8698578f00@default>
Date: Fri, 11 May 2012 09:31:53 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FA33DF6.8060107@kernel.org> <20120509201918.GA7288@kroah.com>
 <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com>
 <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com>
 <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org>
 <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org>
 <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org>
 <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default> <4FAC59F6.4080503@kernel.org>
In-Reply-To: <4FAC59F6.4080503@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
>=20
> Hi Dan,
>=20
> At least, zram is also primary user and it also has such mess although it=
's not severe than zcache.
> zram->table[index].handle sometime has real (void*) handle, sometime (str=
uct page*).
> And I assume ramster you sent yesterday will be.
>=20
> I think there are already many mess and I bet it will prevent going to ma=
inline.
> Especially, handle problem is severe because it a arguement of most funct=
ions exported in zsmalloc
> So, we should clean up before late, IMHO.
>=20
> > zcache is going to need more access to the internals
> > of its allocator, not less.  Zsmalloc is currently missing
> > some important functionality that (I believe) will be
> > necessary to turn zcache into an enterprise-ready,
>=20
> If you have such TODO list, could you post it?
> It helps direction point of my stuff.

Will you be proposing to promote zram and zsmalloc out of staging
for the upcoming window?  If so, I will try to make some time
for this.  Otherwise, I apologize, but I will need to
wait a week or two (after the upcoming window) when I will
have more time.
=20
> > always-on kernel feature.  If it evolves to add that
> > functionality, then it may no longer be able to provide
> > generic abstract access... in which case generic zsmalloc
> > may then have zero users in the kernel.
>=20
> Hmm, Do you want to make zsmalloc by zcache owned private allocator?

I would prefer to use only zsmalloc, but it currently cannot provide
all the functionality of "zbud" which is a private allocator in
zcache and ramster.  I'll explain more later.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

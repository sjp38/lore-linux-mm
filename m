Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id DE2796B0024
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 20:35:51 -0500 (EST)
Message-ID: <5111B318.9020204@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 09:34:16 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: rename confusing function names
References: <51113CE3.5090000@gmail.com> <20130205192640.GC6481@cmpxchg.org> <20130205141332.04fcceac.akpm@linux-foundation.org> <5111AC7D.9070505@cn.fujitsu.com> <20130205172057.3be4dbd4.akpm@linux-foundation.org>
In-Reply-To: <20130205172057.3be4dbd4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com, linux-kernel@vger.kernel.org

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8806=E6=97=A5 09:20, Andrew Morton =E5=86=
=99=E9=81=93:
> On Wed, 06 Feb 2013 09:06:05 +0800
> Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:
>=20
>> So could I rename the functions to the names like
>> nr=5Favailable=5Fbuffer=5Fhigh=5Fpages
>> And accurately document them with code comments just as you suggested.
>=20
> gee.  "available" implies "available for you to allocate".  It has the
> same problem as "free".
>=20
> And "buffer" shouldn't be there - that's a reflection of the fact
> that buffer=5Fhead payloads are not allocated from highmem.  An archaic
> irrelevant thing.
>=20
> Seriously, first let's write down the descriptions of what these
> functions *do*.  Then choose nice names which abbreviate that.
>=20

OK, I will try to do this.

>=20
>=20
> hm,
>=20
> static unsigned int nr=5Ffree=5Fzone=5Fpages(int offset)
> {
> 	...
> 	unsigned int sum =3D 0;
> 	...
> 	return sum;
> }
>=20
> How long will it be until these things start exploding from
> sums-of-zones which exceed 16TB? =20
>=20

You mean overflow? Hmm.. it might happens. Change the sum to
unsigned long is ok?

Thanks
Zhang Yanfei

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

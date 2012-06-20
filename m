Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id E48F16B0070
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:25:17 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <71fe129f-25c2-471b-b3f1-42706ba31048@default>
Date: Wed, 20 Jun 2012 08:24:04 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: help converting zcache from sysfs to debugfs?
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
 <CAPbh3rtA3AcR3TU2-dGpgLOR-TfkXcGAmZJASDwAdsEi_GfK-w@mail.gmail.com>
In-Reply-To: <CAPbh3rtA3AcR3TU2-dGpgLOR-TfkXcGAmZJASDwAdsEi_GfK-w@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>

> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> Subject: Re: help converting zcache from sysfs to debugfs?
>=20
> On Jun 19, 2012 8:30 PM, "Dan Magenheimer" <dan.magenheimer@oracle.com> w=
rote:
> >
> > Zcache (in staging) has a large number of read-only counters that
> > are primarily of interest to developers.  These counters are currently
> > visible from sysfs.  However sysfs is not really appropriate and
> > zcache will need to switch to debugfs before it can be promoted
> > out of staging.
> >
> > For some of the counters, it is critical that they remain accurate so
> > an atomic_t must be used.  But AFAICT there is no way for debugfs
> > to work with atomic_t.
>=20
> Which ones must be atomic? Do they really need to be atomic if they are f=
or diagnostics/developers?
>  :
> A dozen that _MUST_ be atomic?

Hi Konrad --

On second look, there are only eight.  They are unsigned, go
up and down, and the code needs to know if/when they are zero
(or BUG if they go below zero).  When viewed by a developer
(or very savvy administrator), they can be viewed directly or
feed into analysis tools that would likely get very confused
by "huge" ("negative unsigned") values.  Recently, Seth changed
one zcache counter from unsigned to atomic_t for this reason.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

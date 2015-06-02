Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2333E6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 10:25:23 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so101711926qko.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 07:25:23 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id l4si15813856qge.125.2015.06.02.07.25.21
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 07:25:22 -0700 (PDT)
Date: Tue, 2 Jun 2015 10:25:20 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH 0/3] Allow user to request memory to be locked on
 page fault
Message-ID: <20150602142520.GB2364@akamai.com>
References: <1432908808-31150-1-git-send-email-emunson@akamai.com>
 <20150601152746.abbbbb9d479c0e2dbdec2aaf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GRPZ8SYKNexpdSJ7"
Content-Disposition: inline
In-Reply-To: <20150601152746.abbbbb9d479c0e2dbdec2aaf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 01 Jun 2015, Andrew Morton wrote:

> On Fri, 29 May 2015 10:13:25 -0400 Eric B Munson <emunson@akamai.com> wro=
te:
>=20
> > mlock() allows a user to control page out of program memory, but this
> > comes at the cost of faulting in the entire mapping when it is
> > allocated.  For large mappings where the entire area is not necessary
> > this is not ideal.
> >=20
> > This series introduces new flags for mmap() and mlockall() that allow a
> > user to specify that the covered are should not be paged out, but only
> > after the memory has been used the first time.
>=20
> I almost applied these, but the naming issue (below) stopped me.
>=20
> A few things...
>=20
> - The 0/n changelog should reveal how MAP_LOCKONFAULT interacts with
>   rlimit(RLIMIT_MEMLOCK).
>=20
>   I see the implementation is "as if the entire mapping will be
>   faulted in" (for mmap) and "as if it was MCL_FUTURE" (for mlockall)
>   which seems fine.  Please include changelog text explaining and
>   justifying these decisions.  This stuff will need to be in the
>   manpage updates as well.

Change logs are updated, and this will be included in the man page
update as well.

>=20
> - I think I already asked "why not just use MCL_FUTURE" but I forget
>   the answer ;) In general it is a good idea to update changelogs in
>   response to reviewer questions, because other people will be
>   wondering the same things.  Or maybe I forgot to ask.  Either way,
>   please address this in the changelogs.

I must have missed that question.  Here is the text from the updated
mlockall changelog:

MCL_ONFAULT is preferrable to MCL_FUTURE for the use cases enumerated
in the previous patch becuase MCL_FUTURE will behave as if each mapping
was made with MAP_LOCKED, causing the entire mapping to be faulted in
when new space is allocated or mapped.  MCL_ONFAULT allows the user to
delay the fault in cost of any given page until it is actually needed,
but then guarantees that that page will always be resident.

>=20
> - I can perhaps see the point in mmap(MAP_LOCKONFAULT) (other
>   mappings don't get lock-in-memory treatment), but what's the benefit
>   in mlockall(MCL_ON_FAULT) over MCL_FUTURE?  (Add to changelog also,
>   please).
>=20
> - Is there a manpage update?

I will send one out when I post V2

>=20
> - Can we rename patch 1/3 from "add flag to ..." to "add mmap flag to
>   ...", to distinguish from 2/3 "add mlockall flag ..."?

Done

>=20
> - The MAP_LOCKONFAULT versus MCL_ON_FAULT inconsistency is
>   irritating!  Can we get these consistent please: switch to either
>   MAP_LOCK_ON_FAULT or MCL_ONFAULT.

Yes, will do for V2.

>=20

--GRPZ8SYKNexpdSJ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVbbzQAAoJELbVsDOpoOa9EtAP+wamgfoxHetODtEfMUqzYJgN
GxcPBHPjo32fPtFoQu+IvDCqI48ySC4Syx0DqjzZJah+Uo8ngxUDQz3U9dTFrZq+
wv18PEj5CV4ejsEPn6pPuFYpQk/s6UvaexGCXONeHD8Zp20zoPpa4foUMyOvvUnC
tTA+fUJNsinYLGmzidV/1ebXUZYA2ur8Keur7e/kVqzZUWCkClpEVa7ZWnclral9
8mcvrgnI0Z7HnXlZzgUzncUt/OpVwp6jH8Cg4l2qGvSN0q4w77LWhac4n+ut7ogZ
XUIZiem41vBBzWuRjI9TiikFv83wQUPgFrlazWaScEl1Ht5N6HBs20EwHS86sBHe
cMk6SdwUhhCi7rRsZQPcYq+Re6XKXMZPUhfoMqU09TMIpN0t01XGdkAQehgHoyvY
N2hI4zuLIiFNYouXQKLwp+a7++tzI7XxfIo67CmdzCEb/Buxalhd+rSOQWF28Sos
F4vRxeyhzE0CjWPcp9qDt4EIJci1TNwvQpOzT0HbX1PXJEJM44cRZxvLIYq9Almy
g0rQ2LSYZP1gf9ngo/zh02ghenboKwYAMVOZDbOOjUMvtw5RS97voJ5ZOX+/fK95
AQAEPZnJICFKmP/yNGtWpKuK3yfeYxDL0mAopbzXe2SGgk9eS6Dgsg0gVI4hyu33
uQVVmWf17Owqb8CI9gAt
=Aoeb
-----END PGP SIGNATURE-----

--GRPZ8SYKNexpdSJ7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

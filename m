Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA40F6B00F7
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:50:25 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so4899896wgg.10
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 07:50:25 -0700 (PDT)
Received: from BlackPearl.yuhu.biz ([85.14.7.126])
        by mx.google.com with ESMTP id di11si17202083wid.13.2014.06.10.07.50.12
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 07:50:13 -0700 (PDT)
Received: from dspam_yuhu (BlackPearl.yuhu.biz [127.0.0.1])
	by BlackPearl.yuhu.biz (Postfix) with SMTP id 0606C1DF182
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:50:05 +0300 (EEST)
Message-ID: <53971B23.8000509@yuhu.biz>
Date: Tue, 10 Jun 2014 17:50:11 +0300
From: Marian Marinov <mm@yuhu.biz>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140416154650.GA3034@alpha.arachsys.com>	<20140418155939.GE4523@dhcp22.suse.cz>	<5351679F.5040908@parallels.com>	<20140420142830.GC22077@alpha.arachsys.com>	<20140422143943.20609800@oracle.com>	<20140422200531.GA19334@alpha.arachsys.com>	<535758A0.5000500@yuhu.biz> <20140423084942.560ae837@oracle.com>
In-Reply-To: <20140423084942.560ae837@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dwight Engen <dwight.engen@oracle.com>
Cc: Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/23/2014 03:49 PM, Dwight Engen wrote:
> On Wed, 23 Apr 2014 09:07:28 +0300
> Marian Marinov <mm@yuhu.biz> wrote:
>=20
>> On 04/22/2014 11:05 PM, Richard Davies wrote:
>>> Dwight Engen wrote:
>>>> Richard Davies wrote:
>>>>> Vladimir Davydov wrote:
>>>>>> In short, kmem limiting for memory cgroups is currently broken.
>>>>>> Do not use it. We are working on making it usable though.
>>> ...
>>>>> What is the best mechanism available today, until kmem limits
>>>>> mature?
>>>>>
>>>>> RLIMIT_NPROC exists but is per-user, not per-container.
>>>>>
>>>>> Perhaps there is an up-to-date task counter patchset or similar?
>>>>
>>>> I updated Frederic's task counter patches and included Max
>>>> Kellermann's fork limiter here:
>>>>
>>>> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>>>>
>>>> I can send you a more recent patchset (against 3.13.10) if you
>>>> would find it useful.
>>>
>>> Yes please, I would be interested in that. Ideally even against
>>> 3.14.1 if you have that too.
>>
>> Dwight, do you have these patches in any public repo?
>>
>> I would like to test them also.
>=20
> Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
>=20
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.14

I did a backport of the patches to 3.12.16 and forward ported them to 3.1=
2.20.

I'm very happy with how they work.

I used the patches on machines with 10-20k processes and it worked perfec=
tly when some of the containers spawned 100s of
processes. It really saved us when one of the containers was attacked :)

The only thing that I'm going to add is on the fly change of the limit.

Marian

> =20
>> Marian
>>
>>>
>>> Thanks,
>>>
>>> Richard.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe cgroups"
>>> in the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20



--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOXGyMACgkQ4mt9JeIbjJSbZwCfYE/EfljGWfMgz0MxBcNArv+1
uIIAnjDyTp++AzAotNpxNRj5ZyBtdi85
=ruWh
-----END PGP SIGNATURE-----

--3GVEq5bqWT2KnhLROH8Ev1bRXASdGQ3PF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

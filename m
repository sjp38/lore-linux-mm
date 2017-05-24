Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C66FF6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:22:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l125so89619753pga.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:22:33 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id s134si11779417pgs.209.2017.05.24.08.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 08:22:33 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id u26so33305870pfd.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:22:33 -0700 (PDT)
Date: Wed, 24 May 2017 23:21:24 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
Message-ID: <20170524152124.GB8445@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
 <20170518090636.GA25471@dhcp22.suse.cz>
 <20170523032705.GA4275@WeideMBP.lan>
 <20170523063911.GC12813@dhcp22.suse.cz>
 <20170524095450.GA7706@WeideMBP.lan>
 <20170524120318.GE14733@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="tjCHc7DPkfUGtrlw"
Content-Disposition: inline
In-Reply-To: <20170524120318.GE14733@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--tjCHc7DPkfUGtrlw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 24, 2017 at 02:03:18PM +0200, Michal Hocko wrote:
>On Wed 24-05-17 17:54:50, Wei Yang wrote:
>> On Tue, May 23, 2017 at 08:39:11AM +0200, Michal Hocko wrote:
>[...]
>> >Is this worth risking breakage of the userspace which consume this data
>> >now? Do you have any user space code which will greatly benefit from the
>> >new data and which couldn't do the same with the current format/output?
>> >
>> >If yes this all should be in the changelog.
>>=20
>> The answer is no.
>>=20
>> I have the same concern as yours. So this patch set could be divided int=
o two
>> parts: 1. add some new entry with current name convention, 2. change the=
 name
>> convention.
>
>Who is going to use those new entries and for what purpose? Why do we
>want to expose even more details of the slab allocator to the userspace.
>Is the missing information something fundamental that some user space
>cannot work without it? Seriously these are essential questions you
>should have answer for _before_ posting the patch and mention all those
>reasons in the changelog.

It is me who wants to get more details of the slub behavior. =20
AFAIK, no one else is expecting this.

Hmm, if we really don't want to export these entries, why not remove related
code? Looks we are sure they will not be touched.

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--tjCHc7DPkfUGtrlw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZJaT0AAoJEKcLNpZP5cTd3kYP/jTCJ3GvIN+kFANMKUlkExUT
dmiDu/YyOVPDSbTcZxhcBzfGHwHGVdIyX/nCEM1yxSVv2cjQ8kNtGD02CrGQliUP
eJ29ETtQLy7b7o+999cUVdrIp4HD2qF8kB8KveEclvxVSD7kw6+qKQvzWBcU1HAc
dDz7Lxojmvaaiy4d+vhMhnPpNrqX65zwSRWwMX88g3rS0WvgmhRCTdieVW2ywmvl
XPbqaS7VAO24myQ1tIVzKhGOlKOWtTURucozxwjt2MeN8PIoroYrkq0G1AgfO+7I
I4In7i3MVsRVIYSw1MTHWXFODI1fD0SuR516uk4ktbFxuso25kTQ0hvU0dno+ooz
qMwAiiASbIij62dxvKhTbPrCGncsaeM+VN6jZyjc+NiTDpKmbCATaBcOlxHt9HVs
Gy0y+jXm+WeKI+/lszbUKpvYAuP5aDSBpgiJkkbMnwoD4DJmpx9C//Z8/2plVI/L
RqVa7JV0pfCNyBWpYtPy/yu7y30wjOcqnkTzQbO79PJIcmVH20erjvZeuup8LytO
PWc9B+RW26uQ9pl4f3V8Zn+TSUwpTeOvwdVq4GEQbH6fOM+Rn9iDx5gEufpsvzfh
pFJWVJUaS2Kv5saorfyMW92gJJ1hMLkpXHquPADMyK0iXkXaR2snqmOoxz4rPtGH
Dlr14dxR+NECvkLNlrXf
=PnzF
-----END PGP SIGNATURE-----

--tjCHc7DPkfUGtrlw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

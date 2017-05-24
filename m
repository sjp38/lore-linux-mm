Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A557A6B036A
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:54:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u187so108483800pgb.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:54:54 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id c188si24289888pfb.309.2017.05.24.02.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 02:54:53 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id s62so16581200pgc.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:54:53 -0700 (PDT)
Date: Wed, 24 May 2017 17:54:50 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
Message-ID: <20170524095450.GA7706@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
 <20170518090636.GA25471@dhcp22.suse.cz>
 <20170523032705.GA4275@WeideMBP.lan>
 <20170523063911.GC12813@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <20170523063911.GC12813@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 23, 2017 at 08:39:11AM +0200, Michal Hocko wrote:
>On Tue 23-05-17 11:27:05, Wei Yang wrote:
>> On Thu, May 18, 2017 at 11:06:37AM +0200, Michal Hocko wrote:
>> >On Wed 17-05-17 22:11:40, Wei Yang wrote:
>> >> This patch serial could be divided into two parts.
>> >>=20
>> >> First three patches refine and adds slab sysfs.
>> >> Second three patches rename slab sysfs.
>> >>=20
>> >> 1. Refine slab sysfs
>> >>=20
>> >> There are four level slabs:
>> >>=20
>> >>     CPU
>> >>     CPU_PARTIAL
>> >>     PARTIAL
>> >>     FULL
>> >>=20
>> >> And in sysfs, it use show_slab_objects() and cpu_partial_slabs_show()=
 to
>> >> reflect the statistics.
>> >>=20
>> >> In patch 2, it splits some function in show_slab_objects() which make=
s sure
>> >> only cpu_partial_slabs_show() covers statistics for CPU_PARTIAL slabs.
>> >>=20
>> >> After doing so, it would be more clear that show_slab_objects() has t=
otally 9
>> >> statistic combinations for three level of slabs. Each slab has three =
cases
>> >> statistic.
>> >>=20
>> >>     slabs
>> >>     objects
>> >>     total_objects
>> >>=20
>> >> And when we look at current implementation, some of them are missing.=
 So patch
>> >> 2 & 3 add them up.
>> >>=20
>> >> 2. Rename sysfs
>> >>=20
>> >> The slab statistics in sysfs are
>> >>=20
>> >>     slabs
>> >>     objects
>> >>     total_objects
>> >>     cpu_slabs
>> >>     partial
>> >>     partial_objects
>> >>     cpu_partial_slabs
>> >>=20
>> >> which is a little bit hard for users to understand. The second three =
patches
>> >> rename sysfs file in this pattern.
>> >>=20
>> >>     xxx_slabs[[_total]_objects]
>> >>=20
>> >> Finally it looks Like
>> >>=20
>> >>     slabs
>> >>     slabs_objects
>> >>     slabs_total_objects
>> >>     cpu_slabs
>> >>     cpu_slabs_objects
>> >>     cpu_slabs_total_objects
>> >>     partial_slabs
>> >>     partial_slabs_objects
>> >>     partial_slabs_total_objects
>> >>     cpu_partial_slabs
>> >
>> >_Why_ do we need all this?
>>=20
>> To have a clear statistics for each slab level.
>
>Is this worth risking breakage of the userspace which consume this data
>now? Do you have any user space code which will greatly benefit from the
>new data and which couldn't do the same with the current format/output?
>
>If yes this all should be in the changelog.

The answer is no.

I have the same concern as yours. So this patch set could be divided into t=
wo
parts: 1. add some new entry with current name convention, 2. change the na=
me
convention.

If there are many userspace tools use these entries, the changing is really
risky, I agree. Hmm, I still send this out, since current name convention i=
s a
little difficult for users to understand, especially after we have several
levels slabs. Is it possible to use the name convention I proposed and add
link to them to keep the userspace interface?

And the second part is to fully utilize current functions. In function
show_slab_objects(), we have 9 combinations of slab statistics. 3 for each
slab level. And currently code just enable 6 of them. So the first three tr=
ies
to enable the missing 3 to make it a more complete statistics.

BTW, I found we don't have any entry for full slabs statistics. Not sure th=
is
is omitted intendedly or not. If the community agrees, I still have a path =
to
enable the statistics for full slabs.

Thanks for your comments~ Michal

>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZJVhqAAoJEKcLNpZP5cTddvEP/3wmi0agqXXyCrnI/yhq+Bf3
W1CO8TezpUKg7AO8+UORoDCaLZW1Xep28oXWE3eNYxYCK/hfkmpVnXBEYlmpFhBd
1RornF783SeL5WnTLySd2BZ8xaz4vEn9tvX8d3WQJHN8Nr68oKMu2WxSi4brVSAc
SjamVB4twCAJrvSb2bFp4PNOKXFG1i+AVz/CU+BcoHOzRbsndZO8bpBk/xzhIIpX
eDC2jZjFIQY/IQJJwbpMloISRv9fgQzOP5FxlR4rxbQNLB410yU/FH7aIyjOufxw
fbnJv8+/mNqVxBnuMUKP//U5LGiWN4orBCEcwmpA/+mfWFU8zQDzikT7WDlRlQb8
McyzFMKy7qhnwWeTV6fgVwbrjd/mzAQIjOVoXaH7Aijim1d5rVlYahMzZJTD0DJW
1Bg+CeUVwkP+JWFUrFHfvoefG3GsZX81ycU6lm380M13yiLdJRUJVGLqFyiTqotD
CoLmjaVPIQ9CpxuSDLwiz9jw7UfxjJLjTcrpGiIX4PipuhwPRsAM+8ARquX5+nb7
yQH3KsHINn9CmCqhjoFS0s0Ol5SZYLGRo9RjPadQU0l6fXvApAsiTsIL4uS+lrhd
7cwrx6W/mK0/vkSvCPCq7XgKAOMMf8BZsd+uOWmvzwztWradsskS3/MkWCpljoQD
+UKCtZVhHt8Hzil7ultn
=f/+A
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

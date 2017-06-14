Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA8806B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:20:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h21so94237675pfk.13
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:20:02 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id e27si1590229pfk.188.2017.06.13.23.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 23:20:02 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y7so25206404pfd.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:20:01 -0700 (PDT)
Date: Wed, 14 Jun 2017 14:19:59 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RESEND PATCH] base/memory: pass the base_section in
 add_memory_block
Message-ID: <20170614061959.GD14009@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170614054550.14469-1-richard.weiyang@gmail.com>
 <20170614055925.GA6045@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="RhUH2Ysw6aD5utA4"
Content-Disposition: inline
In-Reply-To: <20170614055925.GA6045@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--RhUH2Ysw6aD5utA4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 14, 2017 at 07:59:25AM +0200, Michal Hocko wrote:
>On Wed 14-06-17 13:45:50, Wei Yang wrote:
>> Based on Greg's comment, cc it to mm list.
>> The original thread could be found https://lkml.org/lkml/2017/6/7/202
>

Wow, you are still working~ I just moved your response in this thread~

So that other audience would be convenient to see the whole story.

>I have already given you feedback
>http://lkml.kernel.org/r/20170613114842.GI10819@dhcp22.suse.cz
>and you seemed to ignore it completely.
>
>> The second parameter of init_memory_block() is used to calculate the
>> start_section_nr of this block, which means any section in the same block
>> would get the same start_section_nr.
>>=20
>> This patch passes the base_section to init_memory_block(), so that to
>> reduce a local variable and a check in every loop.
>>=20
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  drivers/base/memory.c | 7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index cc4f1d0cbffe..1e903aba2aa1 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -664,21 +664,20 @@ static int init_memory_block(struct memory_block *=
*memory,
>>  static int add_memory_block(int base_section_nr)
>>  {
>>  	struct memory_block *mem;
>> -	int i, ret, section_count =3D 0, section_nr;
>> +	int i, ret, section_count =3D 0;
>> =20
>>  	for (i =3D base_section_nr;
>>  	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
>>  	     i++) {
>>  		if (!present_section_nr(i))
>>  			continue;
>> -		if (section_count =3D=3D 0)
>> -			section_nr =3D i;
>>  		section_count++;
>>  	}
>> =20
>>  	if (section_count =3D=3D 0)
>>  		return 0;
>> -	ret =3D init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLIN=
E);
>> +	ret =3D init_memory_block(&mem, __nr_to_section(base_section_nr),
>> +				MEM_ONLINE);
>>  	if (ret)
>>  		return ret;
>>  	mem->section_count =3D section_count;
>> --=20
>> 2.11.0
>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--RhUH2Ysw6aD5utA4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQNWPAAoJEKcLNpZP5cTdhrMP/jKTVLGQMtrcpVaqAFQpN8Wq
J0kd6J1jlAYeLkK12UUQ3zr9PYvsj5AHG4LLTYmO4KtGp6xUTfKLRfT440AjaVuV
78jXupMQxeASgqn7N54m182eDZ7zg4RWcRnqU0k5fxdHUeuQ74MiEoIx8/U4ced0
ap8Ifv+XJwTRI2wBna5V5l2GsbihYu3RAYaQCK7au/384HiOXJSRU0C566mOwecY
OrFEVmHmYz+Pcvj++BksmfQFsJistimn2sw+sQptzp8IXU7dnWyiDfvnZ1cFU3gE
kCcrPnnDTgwkYOZkwJPtbk1moJKv9tmYrhDNwKH47VTCXXbGIs+e41hr+Q4l0jUR
pxPj6vylcAy/99Z38Soe5G6P1yQ7rcDtRklUA+Stx4ZTszj8sS+tVQV7+Rt76XGi
kapg7XbuOE3SeC6mxZ6JIomaQDTc0aMvi600kjqHd5CC9gDePU9YBRZZaaSRgX9R
DD9eGCQOCr141TDKqguERToaso9D9O70OrWWoGB4ZzXf3H133u43JnQ5ypgYLCTA
BDTRDkyeUqYLIhHquC0W7SLExlZstAkH5/d3wY/MOQFpuGdWmccGMMu/nLWJxz3S
F7LPnBt/IFrKYjpI3PWUk4KiB2q8egQeo5eCQ9ZsFjdccJ2R7+5rYcorWO8HqxlC
rBqpLRhhh3eZc+2ASq+q
=Hr3K
-----END PGP SIGNATURE-----

--RhUH2Ysw6aD5utA4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

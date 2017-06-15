Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 695686B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:03:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so134076pfl.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:03:02 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id n1si1175583pll.207.2017.06.14.18.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:03:01 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y7so6096pfd.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:03:01 -0700 (PDT)
Date: Thu, 15 Jun 2017 09:02:58 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of
 is_zone_device_section
Message-ID: <20170615010258.GA16833@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-5-mhocko@kernel.org>
 <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
 <20170614061259.GB14009@WeideMBP.lan>
 <20170614063206.GF6045@dhcp22.suse.cz>
 <20170614091206.GA15768@WeideMacBook-Pro.local>
 <20170614092438.GM6045@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline
In-Reply-To: <20170614092438.GM6045@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 14, 2017 at 11:24:38AM +0200, Michal Hocko wrote:
>On Wed 14-06-17 17:12:06, Wei Yang wrote:
>> On Wed, Jun 14, 2017 at 08:32:06AM +0200, Michal Hocko wrote:
>> >On Wed 14-06-17 14:12:59, Wei Yang wrote:
>> >[...]
>> >> Hi, Michal
>> >>=20
>> >> Not sure you missed this one or you think this is fine.
>> >>=20
>> >> Hmm... this will not happen since we must offline a whole memory_bloc=
k?
>> >
>> >yes
>> >
>> >> So the memory_hotplug/unplug unit is memory_block instead of mem_sect=
ion?
>> >
>> >yes.
>>=20
>> If this is true, the check_hotplug_memory_range() should be fixed too.
>
>as I've said earlier. There are many code paths which are quite
>confusing and they expect sub-section granularity while they in fact
>won't work with sub memblock granularity. This is a larger project
>I am afraid and it would be great if you are willing to try to
>consolidate that code. I have that on my todo list but there are more
>pressing things to address first for me now.
>

Yep, I am willing to have a try. :-)

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQdzCAAoJEKcLNpZP5cTdBJsP/R9cyJ98EEGJISipQBQV1S2q
LZKAVwyyX5+U/OnJARudZ2hieTe5Ee6NAGrFeT4XITX2eE0/ZydUSOiWQsuP/bC6
ex85INW2A+m2PBAvUQfTkn8ezzDxotO3xsx97InOehsD2PwJ+y4vjzz8mZDWLApv
TMbjTakmlY7MrGChbkpgS5fTsOHMMdJlyFYHR0FuUNagm5Cq1t46EjNrEeo7lnmQ
7ZQx9F5UF7mqypD4dyToDP2PyKz7qF0reL0q1Gqwq9EKvftgU7RFG/jx2ayaEirC
rBxj/AozdGfPKwKPotRM9ypgZEYU7BicvL+5Kfq7ByzgzELvvD+WRBNXlgwvswzd
2vs1WTqLTTOVuDgZT4aOfgwFXTb1DyTyRn7ZjKafOx38cpuPjxiQLIkW4yrZcvXx
LC91Nsm8tTRUhTK9uEcj2JcWij/J4EfR0Ru6shI4pQbudgE1wj1F7NLujeHawc6v
98LeflvmsH9eXp/GmWtswW72NN6oYyYHFdFEDM7ray4faITlC+PrUlD/NT3sLzf+
njR92d0LH3D4B7itD1IRJBQ/913wZ9o5sTFxCABjRabV4XiQhsmbEqznFTfZXlG8
1/wctmVc6UWdRvRt+lcF8oqPt03hjaU3HmZ7BXAIhYhuqjfBPiwRQVyYtNPgDXyg
s5U0lx4SS4JgL7zEXoSq
=nCOR
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

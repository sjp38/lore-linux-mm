Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE1A6B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:17:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a82so94353486pfc.8
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:17:34 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id o13si913586pgr.169.2017.06.13.23.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 23:17:33 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id d5so12963812pfe.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:17:33 -0700 (PDT)
Date: Wed, 14 Jun 2017 14:17:31 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of
 is_zone_device_section
Message-ID: <20170614061731.GC14009@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-5-mhocko@kernel.org>
 <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
 <CADZGycZtBzA7E_nsKSxYZ8HFGQ2cpQqN62G4MfU1E9vwC2UfcQ@mail.gmail.com>
 <20170612064952.GE4145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xesSdrSSBC0PokLI"
Content-Disposition: inline
In-Reply-To: <20170612064952.GE4145@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>


--xesSdrSSBC0PokLI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 12, 2017 at 08:49:53AM +0200, Michal Hocko wrote:
>On Sat 10-06-17 22:58:21, Wei Yang wrote:
>> On Sat, Jun 10, 2017 at 5:56 PM, Wei Yang <richard.weiyang@gmail.com> wr=
ote:
>[...]
>> > Hmm... one question about the memory_block behavior.
>> >
>> > In case one memory_block contains more than one memory section.
>> > If one section is "device zone", the whole memory_block is not visible
>> > in sysfs. Or until the whole memory_block is full, the sysfs is visibl=
e.
>> >
>>=20
>> Ok, I made a mistake here. The memory_block device is visible in this
>> case, while the sysfs link between memory_block and node is not visible
>> for the whole memory_block device.
>
>yes the behavior is quite messy
>
>>=20
>> BTW, current register_mem_sect_under_node() will create the sysfs
>> link between memory_block and node for each pfn, while actually
>> we only need one link between them. If I am correct.
>>=20
>> If you think it is fine, I would like to change this one to create the l=
ink
>> on section base.
>
>My longer term plan was to unify all the code to be either memory block
>or memory section oriented. The first sounds more logical from the user
>visible granularity point of view but there might be some corner cases

This means the granularity of hotplug is memory_block instead of mem_sectio=
n?

While I see the alignment check of add_memory_resource() is SECTION size.

>which would require to use section based approach. I didn't have time to
>study that. If you want to play with that, feel free of course.

Yep, I am really want to help, while these inter-connected concepts makes me
confused. I need to learn more on these.

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--xesSdrSSBC0PokLI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQNT7AAoJEKcLNpZP5cTdJuAP/0ltP8WW1G18Ba5A0Jwo2QfO
Mqwxct1XLdHDcmWfq3fqHwY1HlZevqn7Hd3kkJ76DAx6u2VtcY23A7Q7jVaTagNV
rUL4Iqdc4EK8gBhB7rWfV5XwVhASi8dx8AjMGckTA1Kt0k/8K7D8cixENJYbhdS/
z2IGTP1xkqz3I0o1JPE7BX7uCRBwEgjMiLY6/BcujR8+KmyCyQjrGIAIzUpDw/EX
QmF3F25rYD/hs1zKW50bnSjssPhVNHhz+o0iU8vvjkF4yuNACkW+yNhnF2ySpfT5
yoeQ4TX8gyKtzZx/zlMN99MumqaW/4EW3A9haAEamar6EGyn9CdEDWC6pKqIkvSV
rFm059XAW17KBv1iWbiRF4rMBzfJlK/GVuVs44VWeMxHxzNl3eFPA3kNuetegTMr
Yl2zL9+ZiDUxOdoR5dzMNu9QZy4oZDWll/bQG4XOleWVeyDLeAHbuS22QrroX0Gu
yWv8qj4DqVFEqnFsOveydewZSKmp7350bu14dy2tLceyESr/1SVW+FmHQngJ2R3m
hObKsB9fg3Q/FU8wPUt3IEF6pAaBtOPAAur5Rnf9dboeTjkeSGJjj1D2ubk8yD60
RNQcbq29tD5cCHGcRbQCZhgOqYtKHbVb1ZCgf8NNA7MBlIfIjV+k338YKdphroh0
4TyWm9VTEP4P/wn7tmgy
=Qtse
-----END PGP SIGNATURE-----

--xesSdrSSBC0PokLI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

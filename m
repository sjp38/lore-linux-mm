Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBA96B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:06:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g78so96789408pfg.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:06:55 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id h7si223029plk.473.2017.06.14.02.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 02:06:54 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id a70so22818568pge.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:06:54 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:06:51 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170614090651.GA15288@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan>
 <20170612064502.GD4145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20170612064502.GD4145@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 12, 2017 at 08:45:02AM +0200, Michal Hocko wrote:
>On Mon 12-06-17 12:28:32, Wei Yang wrote:
>> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>> >From: Michal Hocko <mhocko@suse.com>
>> >
>> >movable_node kernel parameter allows to make hotplugable NUMA
>> >nodes to put all the hotplugable memory into movable zone which
>> >allows more or less reliable memory hotremove.  At least this
>> >is the case for the NUMA nodes present during the boot (see
>> >find_zone_movable_pfns_for_nodes).
>> >
>>=20
>> When movable_node is enabled, we would have overlapped zones, right?
>
>It won't based on this patch. See movable_pfn_range

I did grep in source code, but not find movable_pfn_range.

Could you share some light on that?

>
--=20
Wei Yang
Help you, Help me

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQPyqAAoJEKcLNpZP5cTdknUP/i1xLydJ0Jdj8Q3TvZtUZJwk
c/YPUttK1MowMP5UnkdQFwd16I5LIdGOlgI+JDaq19wduxRz35HZGCky9q0zaQdK
/XBSqtWU23062lj31nLer23XSV0RyZDmrymFjMd6oD5Y4EHXoqItw6ZrDjgWTkCj
27uDr4O6LmevYwqcf4G7L+qpovxe9rcJUmgfvUNhwCmudvvuBoRnScnFDBtiUTz6
yGwKNUBID+itzFBr3nvyVP5nzib6+oUEprI9M68QM2xbskyZlth83RdUDNN60z0E
Yynz0hEBq01HQfqUHMakl5bfwWDP3rrOXJLWoDgelSjITsrlfOLDpYirsN4SzQgA
1xgNMh2KouzNoSSIToIBpT3M3fQdJTFhjFfkYbMdMUjeCyp2p1FW/8FHfgORXJSL
ReZ1IJ/BTDKB3+yn96wkfPkFAy8JNneOdIvPFjE9EOOu3zE0YhkJAqHhHTBQcjzM
5k26ADWbKqyzjcB2seiWTs0RFwW8d282Wu84c+M3GkzDTNXLSSK+zilQFo3lOfMD
OX9NMSyqLVQkiH7JxQDrYkrUX1XHoUZ3S98Vm8D1VuOTxcK5RhRuPjhcH/9LZ3Yl
xgjl2FHXI3pZosCYQmwZIdN9LIVV6PbMc20xCAtTGSceWkAUQEnnoxUIQlraJ5ye
md1L7rvZtp9r/IgWK5oh
=UxU0
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

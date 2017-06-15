Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A86C96B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:03:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f185so2668pgc.10
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:03:44 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id a11si1077625pgd.459.2017.06.14.18.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:03:44 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id s66so12117pfs.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:03:43 -0700 (PDT)
Date: Thu, 15 Jun 2017 09:03:41 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170615010341.GB16833@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan>
 <20170612064502.GD4145@dhcp22.suse.cz>
 <20170614090651.GA15288@WeideMacBook-Pro.local>
 <3e0a47c9-d51d-3d73-e876-abc1c5c81080@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="O5XBE6gyVG5Rl6Rj"
Content-Disposition: inline
In-Reply-To: <3e0a47c9-d51d-3d73-e876-abc1c5c81080@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richard.weiyang@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--O5XBE6gyVG5Rl6Rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 14, 2017 at 11:07:31AM +0200, Vlastimil Babka wrote:
>On 06/14/2017 11:06 AM, Wei Yang wrote:
>> On Mon, Jun 12, 2017 at 08:45:02AM +0200, Michal Hocko wrote:
>>> On Mon 12-06-17 12:28:32, Wei Yang wrote:
>>>> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>>>>> From: Michal Hocko <mhocko@suse.com>
>>>>>
>>>>> movable_node kernel parameter allows to make hotplugable NUMA
>>>>> nodes to put all the hotplugable memory into movable zone which
>>>>> allows more or less reliable memory hotremove.  At least this
>>>>> is the case for the NUMA nodes present during the boot (see
>>>>> find_zone_movable_pfns_for_nodes).
>>>>>
>>>>
>>>> When movable_node is enabled, we would have overlapped zones, right?
>>>
>>> It won't based on this patch. See movable_pfn_range
>>=20
>> I did grep in source code, but not find movable_pfn_range.
>
>This patch is adding it.
>

Oops, what a shame.

>> Could you share some light on that?
>>=20
>>>

--=20
Wei Yang
Help you, Help me

--O5XBE6gyVG5Rl6Rj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQdztAAoJEKcLNpZP5cTdvtUP/ivNRBF8J0M48Hv8o2CoS4sV
7F9mU++NrxwRo4EVHg9eZxOFw5CVVq4pJUrx41b0wLTGGYSv/WMqWmmPYEwW/cL/
qXUZD+lHNcJYqvXVl39mWv3dLytrdo9kpdZ1BsYCsRyavkRwfl3KSkkpfAiXsOCC
62v25qYz8Gl0hQlMU4Hb2P0mSCgRStqZfz5vKe3/3qC+FuPCHFXwC0NI+TcxFGNe
rcUXfCdQOhloWFT+XDlLnPj3cHU7s4KeqKQ9VYokLWWoS061yucmhfajk9twAcXh
TKTp+jn34X7Xp0DCBQ5smJapbWK5yvacvRr7HcLJUCXsyWVbVuT6/gx//jZCUtOW
HQTSQyl1j1q+RcugsG3rtotbBFGPnDH74jPVciGmRc6q8BmuoObsCtU4x/T4YyaC
utJONKxzrTX5JzlQDvHnqaBJ8F0sdv2CANLd8Ya9T90mcQ0jbjvIDvHxzAq3wN5M
QzNLYJ65iXZkxVBzNO4nKvN9Ad55Fbi1YcmA6Zc1wtcykISQZ323Fgk59g7AlCqL
/iSeizg61oocg4nMRMj93Mg9qW9i1W6N4xuG+ccPMasjvG7+Tvhm0AE2bn5GZGKf
Vsod126/0/EpCnQY+P6/nDCGs9YGSDY+4zREPnV/g/cW9dLVraGr5wlr16kqUiMs
sIrDALMbc3pJhMluZNHQ
=djpe
-----END PGP SIGNATURE-----

--O5XBE6gyVG5Rl6Rj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

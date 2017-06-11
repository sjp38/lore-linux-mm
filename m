Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAF966B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 21:45:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o74so38925337pfi.6
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 18:45:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor588095pld.5.2017.06.10.18.45.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Jun 2017 18:45:36 -0700 (PDT)
Date: Sun, 11 Jun 2017 09:45:35 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170611014535.GA6206@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>movable_node kernel parameter allows to make hotplugable NUMA
>nodes to put all the hotplugable memory into movable zone which
>allows more or less reliable memory hotremove.  At least this
>is the case for the NUMA nodes present during the boot (see
>find_zone_movable_pfns_for_nodes).
>
>This is not the case for the memory hotplug, though.
>
>	echo online > /sys/devices/system/memory/memoryXYZ/status
>
>will default to a kernel zone (usually ZONE_NORMAL) unless the
>particular memblock is already in the movable zone range which is not
>the case normally when onlining the memory from the udev rule context
>for a freshly hotadded NUMA node. The only option currently is to have a
>special udev rule to echo online_movable to all memblocks belonging to
>such a node which is rather clumsy. Not the mention this is inconsistent
>as well because what ended up in the movable zone during the boot will
>end up in a kernel zone after hotremove & hotadd without special care.
>

A kernel zone here means? Which is the counterpart in zone_type? or a
combination of several zone_type?


--=20
Wei Yang
Help you, Help me

--AhhlLboLdkugWU4S
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZPKC/AAoJEKcLNpZP5cTd7wsP/RLDVLblTyjPE11IV+fnDbRG
/P+/D7b28yLzKQ/LCL6knjX07rL1F3cB99wdn9M87MDDNiBwXgqW1A2wIlKMsvdr
03ZByuGnL+iBtqoLUhUqHm2rRxEWmLBnG/d3Xa8ZGOm2v6dKkxbshMswyj0b3T58
2uKL4Tsn7sGekJGmIt2Nibdzkw8sWzgIxiENwgTQfedbC1OUUal5hWPHFBPzzQCB
Ouoi+NX3ETOwxhO1SO12CqR4QEhtZVcc+NXdQ/GgcBbtXuFO6S68N30dxlkC6QED
HILWJd63RLOIDU3PBQWt2SULiS4tzRmVQd4q1DwQr6YJQT2QrY+b/MQ3Exgd9SbL
deYpnLTFmIau3f7WynsllsJaM7MuZHnHFVYxboudvDhxApt4I057nGmX8MHp2Oii
f3XdWlNXLbG+14EgR0WBkPJSk4yJnmzmcGLtDPdlg/C8D55kimTCd9QhkU76BWEE
8L1TP1dhR/QdMPApYDHbjOF7WDxoL05d2AUaqz9BiwE/HP7GWsVnCfSPuIEhMOE5
ZzQuhqhs/wuu+fsIZ7l0W8+SdILqSJSLj5Z2h3B8R8PTnkC0Jyzm9jGpwSmnMpdj
OPly4r2kg1fWzc0rx1b7UbSvWHC6fsq6asMNL0Dz3FGe7eE5cHkELPZmyo3mDo6R
ko9Hi1cVkH+p/Tz7z3iW
=fEc5
-----END PGP SIGNATURE-----

--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

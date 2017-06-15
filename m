Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6599E6B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 23:13:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u8so1910565pgo.11
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:13:58 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id j61si1333396plb.197.2017.06.14.20.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 20:13:57 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id s66so321807pfs.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:13:57 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:13:54 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170615031354.GC16833@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan>
 <20170612064502.GD4145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="m51xatjYGsM+13rf"
Content-Disposition: inline
In-Reply-To: <20170612064502.GD4145@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--m51xatjYGsM+13rf
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
>

Ok, I went through the code and here maybe a question not that close related
to this patch.

I did some experiment with qemu+kvm and see this.

Guest config: 8G RAM, 2 nodes with 4G on each
Guest kernel: 4.11
Guest kernel command: kernelcore=3D1G

The log message in kernel is:

[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000023fffffff]
[    0.000000] Movable zone start for each node
[    0.000000]   Node 0: 0x0000000100000000
[    0.000000]   Node 1: 0x0000000140000000

We see on node 2, ZONE_NORMAL overlap with ZONE_MOVABLE.=20
[0x0000000140000000 - 0x000000023fffffff] belongs to both ZONE.

My confusion is:

After we enable ZONE_MOVABLE, no matter whether it is enabled by
"movable_node" or "kernelcore", we would face this kind of overlap?=20
Finally, the pages in the overlapped range be belongs to which ZONE?

--=20
Wei Yang
Help you, Help me

--m51xatjYGsM+13rf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQftyAAoJEKcLNpZP5cTdOLEP/2fxKHoMvYc3MtgnpnwRNYvB
Yybf0HCp4bcGqjKk/vB+TKTt38UtRULjXw01OHBH0n8J9mfOVKkw/akeWsMWkCKR
fNWtE5euTS69+ZPPUiuaAJUznCJkQjUg7MzGRdfmmfArTV7QSYKw3R64MenhHDuc
/7o+pw4OPM7yZ+c8OqrGPaAzlakDSgZd1JgThrBc6SW5MyZeTU2abrH15GkjQZef
AdVsf6j7vxv/UD0XrwSZzDLOxti1mvvkNhb+N7ZWB095yw0IKHLi8rSOhRi3lprl
VGFlSb/zjvUNYh9C7Em3BwfxLaiVh6sPqu06gMx0qBWsRrpsUyQ7UH0MfmeLcR8/
OYMEUlUlLerYzGx5uaWefL0BengUte5vcQB4ABwh0XnQwZsml3o7d4JiNnkN7REh
maqK4M6eYatEC8HMs+cI4lJklR8rji0jvsyXAVnnqyZtnQS5+uesQrw0MiilYdzd
3z2PtIQ7kUCXB+Eet/iYcWrJJgsu54vyBSSc0KSS4SPuOi59r3raxBaUUamCIEn8
ohe6rWtVd4ajuQGjFUMOH8MZTW2grLxvZVKbI5rCbJaCQa2YWarY6WPcgicvPANM
wQW4eFSE2RnLcqia1Qlbrix9VXKkYyFDiMZsczPenxnehNOT4pl/YcmAsgSS8h+7
cbM/z3uFulZs/cBZQtuz
=sp+C
-----END PGP SIGNATURE-----

--m51xatjYGsM+13rf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

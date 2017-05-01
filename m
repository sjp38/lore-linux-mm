Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8FB6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 17:56:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s89so34526477pfk.11
        for <linux-mm@kvack.org>; Mon, 01 May 2017 14:56:37 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id z27si15620745pfg.270.2017.05.01.14.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 14:56:36 -0700 (PDT)
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
 <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ce589129-d86c-ba43-7e04-55acf08f7f29@nvidia.com>
Date: Mon, 1 May 2017 14:56:34 -0700
MIME-Version: 1.0
In-Reply-To: <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On 05/01/2017 02:04 PM, Reza Arbab wrote:
> On Mon, May 01, 2017 at 01:41:55PM -0700, John Hubbard wrote:
>> 1. A way to move pages between NUMA nodes, both virtual address and phys=
ical=20
>> address-based, from kernel mode.
>=20
> J=C3=A9r=C3=B4me's migrate_vma() and migrate_dma() should have this cover=
ed, including=20
> DMA-accelerated copy.

Yes, that's good. I wasn't sure from this discussion here if either or both=
 of those=20
would be used, but now I see.

Are those APIs ready for moving pages between NUMA nodes? As there is no NU=
MA node=20
id in the API, are we relying on the pages' membership (using each page and=
 updating=20
which node it is on)?

>=20
>> 5. Something to handle the story of bringing NUMA nodes online and putti=
ng them=20
>> back offline, given that they require a device driver that may not yet h=
ave been=20
>> loaded. There are a few minor missing bits there.
>=20
> This has been prototyped with the driver doing memory hotplug/hotremove. =
Could you=20
> elaborate a little on what you feel is missing?
>=20

We just worked through how to deal with this in our driver, and I remember =
feeling=20
worried about the way NUMA nodes can only be put online via a user space ac=
tion=20
(through sysfs). It seemed like you'd want to do that from kernel as well, =
when a=20
device driver gets loaded.

I was also uneasy about user space trying to bring a node online before the=
=20
associated device driver was loaded, and I think it would be nice to be sur=
e that=20
that whole story is looked at.

The theme here is that driver load/unload is, today, independent from the N=
UMA node=20
online/offline, and that's a problem. Not a huge one, though, just worth en=
umerating=20
here.

thanks
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

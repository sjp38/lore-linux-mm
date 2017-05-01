Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29ED86B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 19:58:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y4so50124202pge.16
        for <linux-mm@kvack.org>; Mon, 01 May 2017 16:58:18 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 192si6468421pfu.99.2017.05.01.16.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 16:58:17 -0700 (PDT)
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
 <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
 <ce589129-d86c-ba43-7e04-55acf08f7f29@nvidia.com>
 <20170501235123.2k372i75vxlw5n75@arbab-vm>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d7e4b032-0c73-92fa-9c70-fbda98df849c@nvidia.com>
Date: Mon, 1 May 2017 16:58:14 -0700
MIME-Version: 1.0
In-Reply-To: <20170501235123.2k372i75vxlw5n75@arbab-vm>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On 05/01/2017 04:51 PM, Reza Arbab wrote:
> On Mon, May 01, 2017 at 02:56:34PM -0700, John Hubbard wrote:
>> On 05/01/2017 02:04 PM, Reza Arbab wrote:
>>> On Mon, May 01, 2017 at 01:41:55PM -0700, John Hubbard wrote:
>>>> 1. A way to move pages between NUMA nodes, both virtual address and ph=
ysical=20
>>>> address-based, from kernel mode.
>>>
>>> J=C3=A9r=C3=B4me's migrate_vma() and migrate_dma() should have this cov=
ered, including=20
>>> DMA-accelerated copy.
>>
>> Yes, that's good. I wasn't sure from this discussion here if either or b=
oth of=20
>> those would be used, but now I see.
>>
>> Are those APIs ready for moving pages between NUMA nodes? As there is no=
 NUMA node=20
>> id in the API, are we relying on the pages' membership (using each page =
and=20
>> updating which node it is on)?
>=20
> Yes. Those APIs work by callback. The alloc_and_copy() function you provi=
de will be=20
> called at the appropriate point in the migration. Yours would allocate fr=
om a=20
> specific destination node, and copy using DMA.
>=20

hmmm, that reminds me: the whole story of "which device is this, and which =
NUMA node=20
does it correlate to?" will have to be wired up. That is *probably* all in =
the=20
device driver, but since I haven't worked through it, I'd be inclined to li=
st it as=20
an item on the checklist, just in case it requires some little hook in the =
upstream=20
kernel.

thanks,
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

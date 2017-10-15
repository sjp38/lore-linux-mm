Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 644F36B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 04:07:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s2so4293130pge.19
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 01:07:48 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0086.outbound.protection.outlook.com. [104.47.0.86])
        by mx.google.com with ESMTPS id z1si2405657pll.387.2017.10.15.01.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 15 Oct 2017 01:07:47 -0700 (PDT)
From: Guy Shattah <sguy@mellanox.com>
Subject: RE: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Sun, 15 Oct 2017 08:07:43 +0000
Message-ID: <AM6PR0502MB378337FC360EBB016F179A30BD4E0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
In-Reply-To: <20171012014611.18725-4-mike.kravetz@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>



On 13/10/2017 19:17, Michal Hocko wrote:
> On Fri 13-10-17 10:56:13, Cristopher Lameter wrote:
>> On Fri, 13 Oct 2017, Michal Hocko wrote:
>>
>>>> There is a generic posix interface that could we used for a variety=20
>>>> of specific hardware dependent use cases.
>>> Yes you wrote that already and my counter argument was that this=20
>>> generic posix interface shouldn't bypass virtual memory abstraction.
>> It does do that? In what way?
> availability of the virtual address space depends on the availability=20
> of the same sized contiguous physical memory range. That sounds like=20
> the abstraction is gone to large part to me.

In what way? userspace users will still be working with virtual memory.

>
>>>> There are numerous RDMA devices that would all need the mmap=20
>>>> implementation. And this covers only the needs of one subsystem.=20
>>>> There are other use cases.
>>> That doesn't prevent providing a library function which could be=20
>>> reused by all those drivers. Nothing really too much different from=20
>>> remap_pfn_range.
>> And then in all the other use cases as well. It would be much easier=20
>> if mmap could give you the memory you need instead of havig numerous=20
>> drivers improvise on their own. This is in particular also useful for=20
>> numerous embedded use cases where you need contiguous memory.
> But a generic implementation would have to deal with many issues as=20
> already mentioned. If you make this driver specific you can have=20
> access control based on fd etc... I really fail to see how this is any=20
> different from remap_pfn_range.

Why have several driver specific implementation if you can generalize the i=
dea and implement an already existing POSIX standard?
--
Guy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

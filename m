Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 233DC6B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 03:50:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b192so4268051pga.14
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 00:50:39 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10065.outbound.protection.outlook.com. [40.107.1.65])
        by mx.google.com with ESMTPS id g1si2669071pgc.3.2017.10.15.00.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 15 Oct 2017 00:50:37 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
From: Guy Shattah <sguy@mellanox.com>
Message-ID: <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
Date: Sun, 15 Oct 2017 10:50:29 +0300
MIME-Version: 1.0
In-Reply-To: <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>



On 13/10/2017 19:17, Michal Hocko wrote:
> On Fri 13-10-17 10:56:13, Cristopher Lameter wrote:
>> On Fri, 13 Oct 2017, Michal Hocko wrote:
>>
>>>> There is a generic posix interface that could we used for a variety of
>>>> specific hardware dependent use cases.
>>> Yes you wrote that already and my counter argument was that this generic
>>> posix interface shouldn't bypass virtual memory abstraction.
>> It does do that? In what way?
> availability of the virtual address space depends on the availability of
> the same sized contiguous physical memory range. That sounds like the
> abstraction is gone to large part to me.
In what way? userspace users will still be working with virtual memory.

>
>>>> There are numerous RDMA devices that would all need the mmap
>>>> implementation. And this covers only the needs of one subsystem. There are
>>>> other use cases.
>>> That doesn't prevent providing a library function which could be reused
>>> by all those drivers. Nothing really too much different from
>>> remap_pfn_range.
>> And then in all the other use cases as well. It would be much easier if
>> mmap could give you the memory you need instead of havig numerous drivers
>> improvise on their own. This is in particular also useful
>> for numerous embedded use cases where you need contiguous memory.
> But a generic implementation would have to deal with many issues as
> already mentioned. If you make this driver specific you can have access
> control based on fd etc... I really fail to see how this is any
> different from remap_pfn_range.
Why have several driver specific implementation if you can generalize 
the idea and implement
an already existing POSIX standard?
--
Guy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

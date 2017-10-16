Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 125BE6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 07:09:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n89so8495322pfk.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 04:09:15 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00073.outbound.protection.outlook.com. [40.107.0.73])
        by mx.google.com with ESMTPS id 129si3936235pgi.726.2017.10.16.04.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 04:09:14 -0700 (PDT)
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
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <xa1t60bfxtzw.fsf@mina86.com>
From: Guy Shattah <sguy@mellanox.com>
Message-ID: <267dbccf-5649-7a7c-b85d-66546c0913cc@mellanox.com>
Date: Mon, 16 Oct 2017 14:09:03 +0300
MIME-Version: 1.0
In-Reply-To: <xa1t60bfxtzw.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>



On 16/10/2017 13:33, Michal Nazarewicz wrote:
> On Sun, Oct 15 2017, Guy Shattah wrote:
>> Why have several driver specific implementation if you can generalize
>> the idea and implement an already existing POSIX standard?
> Why is there a need for contiguous allocation?

This was explained in detail during a talk delivered by me and 
Christopher Lameter
during Plumbers conference 2017 @ 
https://linuxplumbersconf.org/2017/ocw/proposals/4669
Please see the slides there.

> If generalisation is the issue, then the solution is to define a common
> API where user-space can allocate memory *in the context of* a device.
> This provides a a??give me memory I can use for this devicea?? request which
> is what user space really wants.
Do you suggest to add a whole new common API instead of merely adding a 
flag to existing one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

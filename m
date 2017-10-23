Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C26C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 11:27:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s75so11975423pgs.12
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:27:53 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u21si5480718pfl.480.2017.10.23.08.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 08:27:44 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710161058470.12436@nuc-kabylake>
 <20171016174229.pz3o4uhzz3qbrp6n@dhcp22.suse.cz>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <2447359e-6d22-4fdc-c48a-3912bfbb69b7@nvidia.com>
Date: Mon, 23 Oct 2017 10:25:07 -0500
MIME-Version: 1.0
In-Reply-To: <20171016174229.pz3o4uhzz3qbrp6n@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>
Cc: Guy Shattah <sguy@mellanox.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/16/2017 12:42 PM, Michal Hocko wrote:
> On Mon 16-10-17 11:00:19, Cristopher Lameter wrote:
>> On Mon, 16 Oct 2017, Michal Hocko wrote:
>>> That being said, the list is far from being complete, I am pretty sure
>>> more would pop out if I thought more thoroughly. The bottom line is tha=
t
>>> while I see many problems to actually implement this feature and
>>> maintain it longterm I simply do not see a large benefit outside of a
>>> very specific HW.
>> There is not much new here in terms of problems. The hardware that
>> needs this seems to become more and more plentiful. That is why we need =
a
>> generic implementation.
> It would really help to name that HW and other potential usecases
> independent on the HW because I am rather skeptical about the
> _plentiful_ part. And so I really do not see any foundation to claim
> the generic part. Because, fundamentally, it is the HW which requires
> the specific memory placement/physically contiguous range etc. So the
> generic implementation doesn't really make sense in such a context.
>

There are TLB's in AMD Xen that can take advantage of contig memory to
improve TLB coverage.=C2=A0 AFAIK contig is not functionally required, its
purely a performance optimization.=C2=A0 Current Xen TLB implementation
doesn't support arbitrary contig lengths, page sizes, etc, but its a
start.=C2=A0 This
type of TLB optimization can be handled on the back end by de-fragging
phys mem (when possible) now that both base and THPs can be easily
migrated; no need for up-front contig, but defrag isn't free either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

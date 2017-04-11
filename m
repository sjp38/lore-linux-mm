Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9A086B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 02:38:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i13so50399104qki.16
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:38:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s39si15581941qtb.313.2017.04.10.23.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 23:38:43 -0700 (PDT)
Date: Tue, 11 Apr 2017 08:38:34 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411083834.765c2201@nial.brq.redhat.com>
In-Reply-To: <20170410160941.GJ4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
	<20170410162749.7d7f31c1@nial.brq.redhat.com>
	<20170410160941.GJ4618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon, 10 Apr 2017 18:09:41 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 10-04-17 16:27:49, Igor Mammedov wrote:
> [...]
> > -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
> > -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=0  
> 
> are you sure both of them should be node=0?
> 
> What is the full comman line you use?
CLI for issue 1, 3:
-enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node \
-drive if=virtio,file=disk.img -kernel bzImage -append 'root=/dev/vda1' \
-object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
-device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=0

for issue2:
-enable-kvm -m 2G,slots=4,maxmem=4G -smp 4 -numa node -numa node \
-drive if=virtio,file=disk.img -kernel bzImage -append 'root=/dev/vda1' \
-object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
-device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

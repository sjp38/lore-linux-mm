Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 912D96B03A1
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:51:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a80so16955561wrc.19
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 14:51:14 -0700 (PDT)
Received: from mail-wr0-x22d.google.com (mail-wr0-x22d.google.com. [2a00:1450:400c:c0c::22d])
        by mx.google.com with ESMTPS id 134si13237112wmn.151.2017.04.17.14.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 14:51:13 -0700 (PDT)
Received: by mail-wr0-x22d.google.com with SMTP id l28so90401217wre.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 14:51:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170411170317.GB21171@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org> <20170411170317.GB21171@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Mon, 17 Apr 2017 14:51:12 -0700
Message-ID: <CAA9_cmdrNZkOByvSecmocqs=6o8ZP5bz+Zx6NrwqjU66C=5Y4w@mail.gmail.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue, Apr 11, 2017 at 10:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
> All the reported issue seem to be fixed and pushed to my git tree
> attempts/rewrite-mem_hotplug branch. I will wait a day or two for more
> feedback and then repost for the inclusion. I would really appreaciate
> more testing/review!

This still seems to be based on 4.10? It's missing some block-layer
fixes and other things that trigger failures in the nvdimm unit tests.
Can you rebase to a more recent 4.11-rc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

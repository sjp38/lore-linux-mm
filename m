Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F83A6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 22:51:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b10so133868682pgn.8
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:51:57 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id z95si4739989plh.321.2017.04.10.19.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 19:51:56 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id o123so27950491pga.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:51:56 -0700 (PDT)
Message-ID: <1491879104.1680.0.camel@gmail.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 11 Apr 2017 12:51:44 +1000
In-Reply-To: <20170410163553.GB31356@redhat.com>
References: <20170410110351.12215-1-mhocko@kernel.org>
	 <20170410163553.GB31356@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon, 2017-04-10 at 12:35 -0400, Jerome Glisse wrote:
> On Mon, Apr 10, 2017 at 01:03:42PM +0200, Michal Hocko wrote:
> > Hi,
> > The last version of this series has been posted here [1]. It has seen
> > some more serious testing (thanks to Reza Arbab) and fixes for the found
> > issues. I have also decided to drop patch 1 [2] because it turned out to
> > be more complicated than I initially thought [3]. Few more patches were
> > added to deal with expectation on zone/node initialization.
> > 
> > I have rebased on top of the current mmotm-2017-04-07-15-53. It
> > conflicts with HMM because it touches memory hotplug as
> > well. We have discussed [4] with JA(C)rA'me and he agreed to
> > rebase on top of this rework [5] so I have reverted his series
> > before applyig mine. I will help him to resolve the resulting
> > conflicts. You can find the whole series including the HMM revers in
> > git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git branch
> > attempts/rewrite-mem_hotplug
> > 
> 
> So updated HMM patchset :
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v20
> 
> I am not posting yet as it seems there is couple thing you need to
> fix in your patchset first. However if you could review :
> 
> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v20&id=84fc68534e781cf6125d02b3bfdba4a51e82d9c9
> 
> As it was your idea, i just want to make sure i didn't denatured
> it :)
> 
> Also as side note, v20 fix build issue by restricting HMM to x86-64
> which is safer than pretending this can be use on any random arch
> as build failures i am getting clearly shows that thing i assumed to
> be true on all arch aren't.

In that case could you please document what an arch needs to do to enable
HMM? What are the dependencies and requirements?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

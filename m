Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC8C6B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:59:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i15so4106492wmf.19
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 01:59:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x64si2102936wmg.142.2017.04.11.01.59.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 01:59:47 -0700 (PDT)
Date: Tue, 11 Apr 2017 10:59:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411085942.GC6729@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410154304.nnegccpcmivqgevo@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410154304.nnegccpcmivqgevo@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon 10-04-17 10:43:04, Reza Arbab wrote:
> On Mon, Apr 10, 2017 at 01:03:42PM +0200, Michal Hocko wrote:
> >This patchset aims at making the onlining semantic more usable. First of
> >all it allows to online memory movable as long as it doesn't clash with
> >the existing ZONE_NORMAL. That means that ZONE_NORMAL and ZONE_MOVABLE
> >cannot overlap. Currently I preserve the original ordering semantic so the
> >zone always precedes the movable zone but I have plans to remove this
> >restriction in future because it is not really necessary.
> 
> Thanks for addressing my issues. I see Igor found a few other things to
> square away, but FWIW,
> 
> Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

OK, I have put this to "[PATCH 6/9] mm, memory_hotplug: do not associate
hotadded memory to zones until online" because that is the core of the
change that you have been testing. Let me know if you want the tag to
other patches as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 383856B039F
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 08:20:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z74so46890659qka.5
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 05:20:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l14si11740648qtl.15.2017.04.03.05.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 05:20:11 -0700 (PDT)
Date: Mon, 3 Apr 2017 14:20:03 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170403142003.7cf74f9c@nial.brq.redhat.com>
In-Reply-To: <20170403115545.GK24661@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
	<20170403115545.GK24661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon, 3 Apr 2017 13:55:46 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 30-03-17 13:54:48, Michal Hocko wrote:
> [...]
> > Any thoughts, complains, suggestions?  
> 
> Anyting? I would really appreciate a feedback from IBM and Futjitsu guys
> who have shaped this code last few years. Also Igor and Vitaly seem to
> be using memory hotplug in virtualized environments. I do not expect
> they would see a huge advantage of the rework but I would appreciate
> to give it some testing to catch any potential regressions.
I really appreciate this rework as it simplifies code a bit and potentially
would allow me/Vitaly to make auto-online work with movable zone as well.

I'll try to test the series within this week.

> 
> I plan to repost the series and would like to prevent from pointless
> submission if there are any obvious issues.
> 
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

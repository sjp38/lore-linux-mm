Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA956B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 10:27:17 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so9834118pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 07:27:17 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bv5si2232780pdb.154.2015.08.04.07.27.16
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 07:27:16 -0700 (PDT)
Message-ID: <55C0CBC3.2000602@intel.com>
Date: Tue, 04 Aug 2015 07:27:15 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com> <55BEE99E.8090901@intel.com> <55C011A6.1090003@huawei.com>
In-Reply-To: <55C011A6.1090003@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/03/2015 06:13 PM, Xishi Qiu wrote:
> How did you do the experiment?

I just stuck in some counters in expand() that looked to see whether the
list was empty or not when the page is added and then printed them out
occasionally.

It will be interesting to see the results both on a freshly-booted
system and one that's reached relatively steady-state and is moving
around a minimal number of pageblocks between the different types.

In any case, the end result here needs to be some indication that the
patch either helps ease fragmentation or helps performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

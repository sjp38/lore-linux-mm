Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 292A96B0313
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:12:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id t30so22240058wra.7
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 04:12:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si9131002wrb.254.2017.06.12.04.12.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 04:12:31 -0700 (PDT)
Date: Mon, 12 Jun 2017 13:12:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v2] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170612111227.GI7476@dhcp22.suse.cz>
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Wei Yang <richard.weiyang@gmail.com>

OK, so here is v2 which fixes 2 typos in the changelog spotted by Wei
Yang and Acked-by from Vlastimil added. No functional changes added.
---

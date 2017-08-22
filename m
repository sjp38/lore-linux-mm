Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C23DB6B04E2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 17:22:42 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 81so2506140ioj.14
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 14:22:42 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id b11si214571itf.162.2017.08.22.14.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 14:22:42 -0700 (PDT)
Date: Tue, 22 Aug 2017 16:22:40 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
In-Reply-To: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
Message-ID: <alpine.DEB.2.20.1708221620060.18344@nuc-kabylake>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Can we simple get rid of the stats or make then configurable (off by
defaut)? I agree they are rarely used and have been rarely used in the past.

Maybe some instrumentation for perf etc will allow
similar statistics these days? Thus its possible to drop them?

The space in the pcp pageset is precious and we should strive to use no
more than a cacheline for the diffs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

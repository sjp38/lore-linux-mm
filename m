Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD0DF2806DC
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 09:26:41 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o124so6135296lfo.9
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:26:41 -0700 (PDT)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id q2si140753lfh.136.2017.08.22.06.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Aug 2017 06:26:40 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH][v2] PM / Hibernate: Feed the wathdog when creating snapshot
Date: Tue, 22 Aug 2017 15:18:08 +0200
Message-ID: <2871816.XzHRS8c6tY@aspire.rjw.lan>
In-Reply-To: <20170822131649.GL9729@dhcp22.suse.cz>
References: <1503372002-13310-1-git-send-email-yu.c.chen@intel.com> <1595884.XH9dSsijkg@aspire.rjw.lan> <20170822131649.GL9729@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chen Yu <yu.c.chen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Tuesday, August 22, 2017 3:16:50 PM CEST Michal Hocko wrote:
> On Tue 22-08-17 14:55:39, Rafael J. Wysocki wrote:
> [...]
> > And you may want to touch the watchdog at the end too in case
> > page_count is small then.
> 
> Why would that be needed? If the number of pages is slow then we will
> release the IRQ lock early and won't need to care about watchdog at all.
> 

Fair enough.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

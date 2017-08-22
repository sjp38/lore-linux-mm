Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD4E2806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 09:16:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b14so13159563wrd.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:16:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y76si13734232wrb.286.2017.08.22.06.16.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 06:16:52 -0700 (PDT)
Date: Tue, 22 Aug 2017 15:16:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][v2] PM / Hibernate: Feed the wathdog when creating
 snapshot
Message-ID: <20170822131649.GL9729@dhcp22.suse.cz>
References: <1503372002-13310-1-git-send-email-yu.c.chen@intel.com>
 <1595884.XH9dSsijkg@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1595884.XH9dSsijkg@aspire.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Chen Yu <yu.c.chen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 22-08-17 14:55:39, Rafael J. Wysocki wrote:
[...]
> And you may want to touch the watchdog at the end too in case
> page_count is small then.

Why would that be needed? If the number of pages is slow then we will
release the IRQ lock early and won't need to care about watchdog at all.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

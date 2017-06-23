Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC1F26B03D2
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:27:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k2so39118468ioe.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:27:09 -0700 (PDT)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id d82si3499443itg.18.2017.06.23.03.27.09
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 03:27:09 -0700 (PDT)
Received: from localhost.localdomain ([127.0.0.1]:57484 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S23992297AbdFWK1HU6KR4 (ORCPT <rfc822;linux-mm@kvack.org>);
        Fri, 23 Jun 2017 12:27:07 +0200
Date: Fri, 23 Jun 2017 12:27:01 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/6] MIPS: do not use __GFP_REPEAT for order-0 request
Message-ID: <20170623102701.GD6306@linux-mips.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623085345.11304-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Alex Belits <alex.belits@cavium.com>, David Daney <david.daney@cavium.com>

Feel free to funnel this upstream with the rest of your series.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Thanks,

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

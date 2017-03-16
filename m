Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA876B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:33:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y17so77391461pgh.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:33:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d124si4418543pgc.413.2017.03.16.00.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 00:33:53 -0700 (PDT)
Date: Thu, 16 Mar 2017 15:34:03 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316073403.GE1661@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315162843.GA27197@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 05:28:43PM +0100, Michal Hocko wrote:
... ...
> After all the amount of the work to be done is the same we just risk
> more lock contentions, unexpected CPU usage etc.

I start to realize this is a good question.

I guess max_active=4 produced almost the best result(max_active=8 is
only slightly better) is due to the test box is a 4 node machine and
therefore, there are 4 zone->lock to contend(let's ignore those tiny
zones only available in node 0).

I'm going to test on a EP to see if max_active=2 will suffice to produce
a good enough result. If so, the proper default number should be the
number of nodes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

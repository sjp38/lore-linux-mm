Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAB46B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:26:32 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so792921lbb.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:26:32 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id n125si499164wmb.87.2016.06.07.02.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 02:26:31 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n184so22547744wmn.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:26:31 -0700 (PDT)
Date: Tue, 7 Jun 2016 11:26:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
Message-ID: <20160607092629.GG12305@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-6-hannes@cmpxchg.org>
 <1465250169.16365.147.camel@redhat.com>
 <20160606221550.GA6665@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606221550.GA6665@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 18:15:50, Johannes Weiner wrote:
[...]
> The last hunk in the patch (obscured by showing the label instead of
> the function name as context)

JFYI my ~/.gitconfig has the following to workaround this:
[diff "default"]
        xfuncname = "^[[:alpha:]$_].*[^:]$"

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

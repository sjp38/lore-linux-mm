Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE20E6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 10:06:57 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id jf8so43516896lbc.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 07:06:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o3si33580883wjl.163.2016.06.07.07.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 07:06:56 -0700 (PDT)
Date: Tue, 7 Jun 2016 10:06:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
Message-ID: <20160607140649.GB9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-6-hannes@cmpxchg.org>
 <1465250169.16365.147.camel@redhat.com>
 <20160606221550.GA6665@cmpxchg.org>
 <20160607092629.GG12305@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160607092629.GG12305@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Tue, Jun 07, 2016 at 11:26:29AM +0200, Michal Hocko wrote:
> On Mon 06-06-16 18:15:50, Johannes Weiner wrote:
> [...]
> > The last hunk in the patch (obscured by showing the label instead of
> > the function name as context)
> 
> JFYI my ~/.gitconfig has the following to workaround this:
> [diff "default"]
>         xfuncname = "^[[:alpha:]$_].*[^:]$"

Thanks, that's useful. I added it to my ~/.gitconfig, so this should
be a little less confusing in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

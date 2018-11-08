Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0B76B05AD
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:02:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h24-v6so6970096ede.9
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:02:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e21-v6si1097479ejq.231.2018.11.08.01.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 01:02:02 -0800 (PST)
Date: Thu, 8 Nov 2018 10:01:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
Message-ID: <20181108090154.GJ2453@dhcp22.suse.cz>
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
 <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
 <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Manning <mmanning@vyatta.att-mail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu 08-11-18 08:30:40, Mike Manning wrote:
[...]
> 1) The original commit was not suitable for backport to 4.14 and should
> be reverted.

Yes, the original patch hasn't been marked for the stable tree and as
such shouldn't have been backported. Even though it looks simple enough
it is not really trivial.

This is not the first time automagic selection has provent to be wrong.
So can we stop this finally please?
-- 
Michal Hocko
SUSE Labs

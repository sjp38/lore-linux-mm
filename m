Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9C966B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:50:38 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id v73so49716325ywg.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:50:38 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z19si714444ywd.230.2017.02.10.09.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:50:38 -0800 (PST)
Date: Fri, 10 Feb 2017 09:50:15 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 5/7] mm: add vmstat account for MADV_FREE pages
Message-ID: <20170210175015.GD86050@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <d12c1b4b571817c0f05a57cc062d91d1a336fce5.1486163864.git.shli@fb.com>
 <20170210132727.GM10893@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170210132727.GM10893@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 10, 2017 at 02:27:27PM +0100, Michal Hocko wrote:
> On Fri 03-02-17 15:33:21, Shaohua Li wrote:
> > Show MADV_FREE pages info in proc/sysfs files.
> 
> How are we going to use this information? Why it isn't sufficient to
> watch for lazyfree events? I mean this adds quite some code and it is
> not clear (at least from the changelog) we we need this information.

It's just like any other meminfo we added to let user know what happens in the
system. Users can use the info for monitoring/diagnosing. the
lazyfree/lazyfreed events can't reflect the lazyfree page info because
'lazyfree - lazyfreed' doesn't equal current lazyfree pages and the events
aren't per-node. I'll add more description in the changelog.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

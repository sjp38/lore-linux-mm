Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFBBE6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 03:02:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so27605601wrb.6
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:02:27 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id d202si11146259wme.110.2017.06.26.00.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 00:02:26 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id 77so28301170wrb.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:02:26 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
 <20170626054623.GC31972@dhcp22.suse.cz>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
Date: Mon, 26 Jun 2017 10:02:23 +0300
MIME-Version: 1.0
In-Reply-To: <20170626054623.GC31972@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

IGBPI?I1I? 26/06/2017 08:46 I?I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> Unfortunatelly, this is not something that can be applied in general.
> This can lead to a premature OOM killer invocations. E.g. a direct write
> to the block device cannot use highmem, yet there won't be anything to
> throttle those writes properly. Unfortunately, our documentation is
> silent about this setting. I will post a patch later.


I should also note that highmem_is_dirtyable was 0 in all the 3.x kernel 
tests that I did; yet they didn't have the "slow disk writes" issue.

I.e. I think that setting highmem_is_dirtyable=1 works around the issue, 
but is not the exact point which caused the regression that we see in 
4.x kernels...

--
Kind regards,
Alkis Georgopoulos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

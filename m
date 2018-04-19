Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0E9E6B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:36:38 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id ay8-v6so3622004plb.9
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:36:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n15si3888857pfj.212.2018.04.19.13.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 13:36:37 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:36:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-Id: <20180419133634.77035d22766e017cd876e170@linux-foundation.org>
In-Reply-To: <c84a30f7-0524-5a30-e825-7e73d0cb06e2@gmail.com>
References: <bug-196157-27@https.bugzilla.kernel.org/>
	<20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
	<20170623071324.GD5308@dhcp22.suse.cz>
	<3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
	<20170623113837.GM5308@dhcp22.suse.cz>
	<a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
	<20170626054623.GC31972@dhcp22.suse.cz>
	<7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
	<20170626091254.GG11534@dhcp22.suse.cz>
	<5eff5b8f-51ab-9749-0da5-88c270f0df92@gmail.com>
	<20170629071619.GB31603@dhcp22.suse.cz>
	<c84a30f7-0524-5a30-e825-7e73d0cb06e2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, reserv0@yahoo.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

https://bugzilla.kernel.org/show_bug.cgi?id=196157

People are still hurting from this.  It does seem a pretty major
regression for highmem machines.

I'm surprised that we aren't hearing about this from distros.  Maybe it
only affects a subset of highmem machines?

Anyway, can we please take another look at it?  Seems that we messed up
highmem dirty pagecache handling in the 4.2 timeframe.

Thanks.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C36826B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:13:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f9-v6so2025064wmc.7
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:13:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j34-v6si2803757edd.367.2018.06.21.08.13.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 08:13:10 -0700 (PDT)
Date: Thu, 21 Jun 2018 17:13:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200105] New: High paging activity as soon as the swap is
 touched (with steps and code to reproduce it)
Message-ID: <20180621151309.GC13063@dhcp22.suse.cz>
References: <bug-200105-27@https.bugzilla.kernel.org/>
 <20180618161735.72a1c9036057ee08d17aaaf4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180618161735.72a1c9036057ee08d17aaaf4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: terragonjohn@yahoo.com
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 18-06-18 16:17:35, Andrew Morton wrote:
[...]
> > I've verified this on various desktop systems, all using SSDs.
> > Obviously, I'm willing to provide more info and to test patches.

Could you snapshot /proc/vmstat during your test please? Once per second
or so should tell us more what is going on.
-- 
Michal Hocko
SUSE Labs

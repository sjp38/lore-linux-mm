Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 50D046B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:08:29 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id ex7so13080303wid.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 06:08:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si73273962wjy.26.2015.02.25.06.08.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 06:08:27 -0800 (PST)
Date: Wed, 25 Feb 2015 15:08:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
Message-ID: <20150225140826.GD26680@dhcp22.suse.cz>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz>
 <20150224191127.GA14718@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1502241220500.3855@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502241220500.3855@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-02-15 12:23:55, David Rientjes wrote:
> On Tue, 24 Feb 2015, Johannes Weiner wrote:
[...]
> > I'm fine with keeping the allocation looping, but is that message
> > helpful?  It seems completely useless to the user encountering it.  Is
> > it going to help kernel developers when we get a bug report with it?
> > 
> > WARN_ON_ONCE()?
> > 
> 
> Yeah, I'm not sure that the warning is helpful (and it needs 
> s/disbaled/disabled/ if it is to be kept).  I also think this check should 
> be moved out of out_of_memory() since gfp/retry logic should be in the 
> page allocator itself and not in the oom killer: just make 
> __alloc_pages_may_oom() also set *did_some_progress = 1 for __GFP_NOFAIL.

OK, this is a good point. Updated patch is below:
---

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2866B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:31:21 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id gm9so8495744lab.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:31:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si33486152wjz.20.2015.01.20.06.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 06:31:20 -0800 (PST)
Date: Tue, 20 Jan 2015 15:31:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - high reclaim
Message-ID: <20150120143119.GK25342@dhcp22.suse.cz>
References: <1421508079-29293-1-git-send-email-hannes@cmpxchg.org>
 <20150120132519.GH25342@dhcp22.suse.cz>
 <20150120141628.GA11181@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120141628.GA11181@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 20-01-15 09:16:28, Johannes Weiner wrote:
> On Tue, Jan 20, 2015 at 02:25:19PM +0100, Michal Hocko wrote:
[...]
> > Is this planned to be folded into the original patch or go on its own. I
> > am OK with both ways, maybe having it separate would be better from
> > documentation POV.
> 
> I submitted them to be folded in.  Which aspect would you like to see
> documented?

That the excess target reclaim has been attempted and changed with a
patch which explains why. So this was kind of "git log as a
documentation" thing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

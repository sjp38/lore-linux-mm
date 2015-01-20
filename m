Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 402456B0082
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:45:03 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id n3so4550569wiv.1
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:45:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gb2si6181495wib.38.2015.01.20.07.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 07:45:02 -0800 (PST)
Date: Tue, 20 Jan 2015 10:44:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - high reclaim
Message-ID: <20150120154456.GA7130@phnom.home.cmpxchg.org>
References: <1421508079-29293-1-git-send-email-hannes@cmpxchg.org>
 <20150120132519.GH25342@dhcp22.suse.cz>
 <20150120141628.GA11181@phnom.home.cmpxchg.org>
 <20150120143119.GK25342@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120143119.GK25342@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 20, 2015 at 03:31:19PM +0100, Michal Hocko wrote:
> On Tue 20-01-15 09:16:28, Johannes Weiner wrote:
> > On Tue, Jan 20, 2015 at 02:25:19PM +0100, Michal Hocko wrote:
> [...]
> > > Is this planned to be folded into the original patch or go on its own. I
> > > am OK with both ways, maybe having it separate would be better from
> > > documentation POV.
> > 
> > I submitted them to be folded in.  Which aspect would you like to see
> > documented?
> 
> That the excess target reclaim has been attempted and changed with a
> patch which explains why. So this was kind of "git log as a
> documentation" thing.

I agreed to soften it because you had reasonable concerns and it was
still strong enough for my tests.  But we hardly "attempted" this
version.  Should this turn out to be too weak for other users in
practice we have to reconsider the stronger approach and actually put
your theory to the test and see if it holds up in practice.  There is
no knowledge to record at this point, we just have speculation and no
real need to push the envelope right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

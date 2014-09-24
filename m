Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A92A86B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 12:51:33 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so7728291wiv.12
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 09:51:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dv7si7476368wib.101.2014.09.24.09.51.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 09:51:32 -0700 (PDT)
Date: Wed, 24 Sep 2014 12:51:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140924165128.GA9968@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144158.GC20398@esperanza>
 <20140922185736.GB6630@cmpxchg.org>
 <20140923110634.GH18526@esperanza>
 <20140923132801.GA14302@cmpxchg.org>
 <20140923152150.GL18526@esperanza>
 <20140923170525.GA28460@cmpxchg.org>
 <20140924133316.GA4558@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924133316.GA4558@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 03:33:16PM +0200, Michal Hocko wrote:
> On Tue 23-09-14 13:05:25, Johannes Weiner wrote:
> [...]
> > How about the following update?  Don't be thrown by the
> > page_counter_cancel(), I went back to it until we find something more
> > suitable.  But as long as it's documented and has only 1.5 callsites,
> > it shouldn't matter all that much TBH.
> > 
> > Thanks for your invaluable feedback so far, and sorry if the original
> > patch was hard to review.  I'll try to break it up, to me it's usually
> > easier to verify new functions by looking at the callers in the same
> > patch, but I can probably remove the res_counter in a follow-up patch.
> 
> The original patch was really huge and rather hard to review. Having
> res_counter removal in a separate patch would be definitely helpful.

Sorry, I just saw your follow-up after sending out v2.  Yes, I split
out the res_counter removal, so the patch is a lot smaller.

> I would even lobby to have the new page_counter in a separate patch with
> the detailed description of the semantic and expected usage. Lockless
> schemes are always tricky and hard to review.

I was considering that (before someone explicitely asked for it) but
ended up thinking it's better to have the API go in along with the
main user, which often helps understanding.  The users of the API are
unchanged, except for requiring callers to serialize limit updates.
And I commented all race conditions inside the counter code, hopefully
that helps, but let me know if things are unclear in v2.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

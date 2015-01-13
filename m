Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id D3FA66B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:45:01 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id p10so5407092wes.9
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:45:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gb7si22638691wib.29.2015.01.13.13.45.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 13:45:01 -0800 (PST)
Date: Tue, 13 Jan 2015 16:44:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150113214454.GA21950@phnom.home.cmpxchg.org>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
 <20150112153716.d54e90c634b70d49e8bb8688@linux-foundation.org>
 <20150113155040.GC8180@phnom.home.cmpxchg.org>
 <20150113125258.0d7d3da2920234fc9461ef69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150113125258.0d7d3da2920234fc9461ef69@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 12:52:58PM -0800, Andrew Morton wrote:
> On Tue, 13 Jan 2015 10:50:40 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Mon, Jan 12, 2015 at 03:37:16PM -0800, Andrew Morton wrote:
> > > This all sounds pretty major.  How much trouble is this change likely to
> > > cause existing memcg users?
> > 
> > That is actually entirely up to the user in question.
> > 
> > 1. The old cgroup interface remains in place as long as there are
> > users, so, technically, nothing has to change unless they want to.
> 
> It would be good to zap the old interface one day.  Maybe we won't ever
> be able to, but we should try.  Once this has all settled down and is
> documented, how about we add a couple of printk_once's to poke people
> in the new direction?

Yup, sounds good to me.

There are a few missing pieces until the development flag can be
lifted from the new cgroup interface.  I'm currently working on making
swap control available, and I expect Tejun to want to push buffered IO
control into the tree before that as well.

But once we have these things in place and are reasonably sure that
the existing use cases can be fully supported by the new interface,
I'm all for nudging people in its direction.  Yes, we should at some
point try to drop the old one, which is going to reduce the code size
significantly, but even before then we can work toward separating out
the old-only parts of the implementation as much as possible to reduce
development overhead from the new/main code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

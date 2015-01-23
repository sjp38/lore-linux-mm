Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 570696B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:04:04 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so8633525wgh.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:04:03 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gl9si4341949wjc.3.2015.01.23.09.04.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 09:04:02 -0800 (PST)
Date: Fri, 23 Jan 2015 12:03:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - "none"
Message-ID: <20150123170353.GA12036@phnom.home.cmpxchg.org>
References: <1421508107-29377-1-git-send-email-hannes@cmpxchg.org>
 <20150120133711.GI25342@dhcp22.suse.cz>
 <20150120143002.GB11181@phnom.home.cmpxchg.org>
 <20150120143644.GL25342@dhcp22.suse.cz>
 <CAOS58YNZFuSP6cKLAkYKkK+QUDxwngnKE5UGHmAL7n3PygraaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOS58YNZFuSP6cKLAkYKkK+QUDxwngnKE5UGHmAL7n3PygraaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Jan 20, 2015 at 12:00:11PM -0500, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jan 20, 2015 at 9:36 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Tue 20-01-15 09:30:02, Johannes Weiner wrote:
> > [...]
> >> Another possibility would be "infinity",
> >
> > yes infinity definitely sounds much better to me.
> 
> FWIW, I prefer "max". It's shorter and clear enough. I don't think
> there's anything ambiguous about "the memory max limit is at its
> maximum". No need to introduce a different term.

While I don't feel too strongly, I do agree with this.  I don't see
much potential for confusion, and "max" is much shorter and sweeter.

Michal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

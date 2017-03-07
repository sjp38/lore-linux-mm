Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0C916B038D
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 17:43:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 187so26499118pgb.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 14:43:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w27si1235413pgc.348.2017.03.07.14.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 14:43:39 -0800 (PST)
Date: Tue, 7 Mar 2017 14:43:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-Id: <20170307144338.023080a8cd600172f37dfe16@linux-foundation.org>
In-Reply-To: <20170307100545.GC28642@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
	<89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
	<20170301133624.GF1124@dhcp22.suse.cz>
	<20170301183149.GA14277@cmpxchg.org>
	<20170301185735.GA24905@dhcp22.suse.cz>
	<20170302140101.GA16021@cmpxchg.org>
	<20170302163054.GR1404@dhcp22.suse.cz>
	<20170303161027.6fe4ceb0bcd27e1dbed44a5d@linux-foundation.org>
	<20170307100545.GC28642@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

On Tue, 7 Mar 2017 11:05:45 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 03-03-17 16:10:27, Andrew Morton wrote:
> > On Thu, 2 Mar 2017 17:30:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > > It's not that I think you're wrong: it *is* an implementation detail.
> > > > But we take a bit of incoherency from batching all over the place, so
> > > > it's a little odd to take a stand over this particular instance of it
> > > > - whether demanding that it'd be fixed, or be documented, which would
> > > > only suggest to users that this is special when it really isn't etc.
> > > 
> > > I am not aware of other counter printed in smaps that would suffer from
> > > the same problem, but I haven't checked too deeply so I might be wrong. 
> > > 
> > > Anyway it seems that I am alone in my position so I will not insist.
> > > If we have any bug report then we can still fix it.
> > 
> > A single lru_add_drain_all() right at the top level (in smaps_show()?)
> > won't kill us
> 
> I do not think we want to put lru_add_drain_all cost to a random
> process reading /proc/<pid>/smaps.

Why not?  It's that process which is calling for the work to be done.

> If anything the one which does the
> madvise should be doing this.

But it would be silly to do extra work in madvise() if nobody will be
reading smaps for the next two months.

How much work is it anyway?  What would be the relative impact upon a
smaps read?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

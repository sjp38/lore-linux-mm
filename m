Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA066B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 19:10:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v190so3861423pfb.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 16:10:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r6si11881259pgf.338.2017.03.03.16.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 16:10:28 -0800 (PST)
Date: Fri, 3 Mar 2017 16:10:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-Id: <20170303161027.6fe4ceb0bcd27e1dbed44a5d@linux-foundation.org>
In-Reply-To: <20170302163054.GR1404@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
	<89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
	<20170301133624.GF1124@dhcp22.suse.cz>
	<20170301183149.GA14277@cmpxchg.org>
	<20170301185735.GA24905@dhcp22.suse.cz>
	<20170302140101.GA16021@cmpxchg.org>
	<20170302163054.GR1404@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

On Thu, 2 Mar 2017 17:30:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > It's not that I think you're wrong: it *is* an implementation detail.
> > But we take a bit of incoherency from batching all over the place, so
> > it's a little odd to take a stand over this particular instance of it
> > - whether demanding that it'd be fixed, or be documented, which would
> > only suggest to users that this is special when it really isn't etc.
> 
> I am not aware of other counter printed in smaps that would suffer from
> the same problem, but I haven't checked too deeply so I might be wrong. 
> 
> Anyway it seems that I am alone in my position so I will not insist.
> If we have any bug report then we can still fix it.

A single lru_add_drain_all() right at the top level (in smaps_show()?)
won't kill us and should significantly improve this issue.  And it
might accidentally make some of the other smaps statistics more
accurate as well.

If not, can we please have a nice comment somewhere appropriate which
explains why LazyFree is inaccurate and why we chose to leave it that
way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8026B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 13:04:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n129so98584793pga.22
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 10:04:32 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id h3si8564953pfe.60.2017.04.08.10.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 10:04:31 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id s16so16708553pfs.0
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 10:04:31 -0700 (PDT)
Date: Sat, 8 Apr 2017 10:04:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
In-Reply-To: <alpine.LSU.2.11.1704071141110.3348@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1704081000110.27995@eggly.anvils>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils> <20170406130614.a6ygueggpwseqysd@techsingularity.net> <alpine.LSU.2.11.1704061134240.17094@eggly.anvils> <alpine.LSU.2.11.1704070914520.1566@eggly.anvils> <20170407163932.GJ16413@dhcp22.suse.cz>
 <alpine.LSU.2.11.1704070952530.2261@eggly.anvils> <20170407172918.GK16413@dhcp22.suse.cz> <alpine.LSU.2.11.1704071141110.3348@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 7 Apr 2017, Hugh Dickins wrote:
> On Fri, 7 Apr 2017, Michal Hocko wrote:
> > On Fri 07-04-17 09:58:17, Hugh Dickins wrote:
> > > On Fri, 7 Apr 2017, Michal Hocko wrote:
> > > > On Fri 07-04-17 09:25:33, Hugh Dickins wrote:
> > > > [...]
> > > > > 24 hours so far, and with a clean /var/log/messages.  Not conclusive
> > > > > yet, and of course I'll leave it running another couple of days, but
> > > > > I'm increasingly sure that it works as you intended: I agree that
> > > > > 
> > > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > > > > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch
> > > > > 
> > > > > should go to Linus as soon as convenient.  Though I think the commit
> > > > > message needs something a bit stronger than "Quite annoying though".
> > > > > Maybe add a line:
> > > > > 
> > > > > Fixes serious hang under load, observed repeatedly on 4.11-rc.
> > > > 
> > > > Yeah, it is much less theoretical now. I will rephrase and ask Andrew to
> > > > update the chagelog and send it to Linus once I've got your final go.
> > > 
> > > I don't know akpm's timetable, but your fix being more than a two-liner,
> > > I think it would be better if it could get into rc6, than wait another
> > > week for rc7, just in case others then find problems with it.  So I
> > > think it's safer *not* to wait for my final go, but proceed on the
> > > assumption that it will follow a day later.
> > 
> > Fair enough. Andrew, could you update the changelog of
> > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > and send it to Linus along with
> > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch before rc6?
> > 
> > I would add your Teste-by Hugh but I guess you want to give your testing
> > more time before feeling comfortable to give it.
> 
> Yes, fair enough: at the moment it's just
> Half-Tested-by: Hugh Dickins <hughd@google.com>
> and I hope to take the Half- off in about 21 hours.
> But I certainly wouldn't mind if it found its way to Linus without my
> final seal of approval.

48 hours and still going well: I declare it good, and thanks to Andrew,
Linus has ce612879ddc7 "mm: move pcp and lru-pcp draining into single wq"
already in for rc6.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

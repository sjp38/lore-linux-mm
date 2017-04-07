Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFCC6B03B2
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:58:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x125so78091885pgb.5
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:58:28 -0700 (PDT)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id m21si5630661pgh.384.2017.04.07.09.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 09:58:27 -0700 (PDT)
Received: by mail-pg0-x22b.google.com with SMTP id g2so70804705pge.3
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:58:27 -0700 (PDT)
Date: Fri, 7 Apr 2017 09:58:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
In-Reply-To: <20170407163932.GJ16413@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1704070952530.2261@eggly.anvils>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils> <20170406130614.a6ygueggpwseqysd@techsingularity.net> <alpine.LSU.2.11.1704061134240.17094@eggly.anvils> <alpine.LSU.2.11.1704070914520.1566@eggly.anvils> <20170407163932.GJ16413@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 7 Apr 2017, Michal Hocko wrote:
> On Fri 07-04-17 09:25:33, Hugh Dickins wrote:
> [...]
> > 24 hours so far, and with a clean /var/log/messages.  Not conclusive
> > yet, and of course I'll leave it running another couple of days, but
> > I'm increasingly sure that it works as you intended: I agree that
> > 
> > mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> > mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch
> > 
> > should go to Linus as soon as convenient.  Though I think the commit
> > message needs something a bit stronger than "Quite annoying though".
> > Maybe add a line:
> > 
> > Fixes serious hang under load, observed repeatedly on 4.11-rc.
> 
> Yeah, it is much less theoretical now. I will rephrase and ask Andrew to
> update the chagelog and send it to Linus once I've got your final go.

I don't know akpm's timetable, but your fix being more than a two-liner,
I think it would be better if it could get into rc6, than wait another
week for rc7, just in case others then find problems with it.  So I
think it's safer *not* to wait for my final go, but proceed on the
assumption that it will follow a day later.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

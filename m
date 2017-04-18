Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB8066B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 04:15:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z129so3641507wmb.23
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:15:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y46si19592738wry.7.2017.04.18.01.15.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 01:15:52 -0700 (PDT)
Date: Tue, 18 Apr 2017 10:15:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
Message-ID: <20170418081549.GJ22360@dhcp22.suse.cz>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
 <alpine.LSU.2.11.1704141726260.9676@eggly.anvils>
 <1492217984.2557.1.camel@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1492217984.2557.1.camel@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Cc: "hughd@google.com" <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "snitzer@redhat.com" <snitzer@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hare@suse.com" <hare@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "jack@suse.cz" <jack@suse.cz>

On Sat 15-04-17 00:59:46, Bart Van Assche wrote:
> On Fri, 2017-04-14 at 17:40 -0700, Hugh Dickins wrote:
> > Changing a fundamental function, silently not to do its essential job,
> > when something in the kernel has forgotten (or is slow to) unlock_page():
> > that seems very wrong to me in many ways.  But linux-fsdevel, Cc'ed, will
> > be a better forum to advise on how to solve the problem you're seeing.
> 
> Hello Hugh,
> 
> It seems like you have misunderstood the purpose of the patch I posted. It's
> neither a missing unlock_page() nor slow I/O that I want to address but a
> genuine deadlock. In case you would not be familiar with the queue_if_no_path
> multipath configuration option, the multipath.conf man page is available at
> e.g. https://linux.die.net/man/5/multipath.conf.

So, whole is holding the page lock and why it cannot make forward
progress? Is the storage gone so that the ongoing IO will never
terminate? Btw. we have many other places which wait for the page lock
!killable way. Why they are any different from this case?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

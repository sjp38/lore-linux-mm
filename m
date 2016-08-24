Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFD7D6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 11:37:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u81so15589214wmu.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 08:37:20 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t81si9437975wmf.64.2016.08.24.08.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 08:37:19 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i138so3146851wmf.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 08:37:19 -0700 (PDT)
Date: Wed, 24 Aug 2016 17:37:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160824153716.GJ31179@dhcp22.suse.cz>
References: <1471968749-26173-1-git-send-email-mhocko@kernel.org>
 <20160823163233.GA7123@redhat.com>
 <20160824081023.GE31179@dhcp22.suse.cz>
 <20160824153159.GA25033@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160824153159.GA25033@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>, William Preston <wpreston@suse.com>

On Wed 24-08-16 17:32:00, Oleg Nesterov wrote:
> On 08/24, Michal Hocko wrote:
> >
> > Sounds better?
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index b89f0eb99f0a..ddde5849df81 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -914,7 +914,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
> >  
> >  	/*
> >  	 * Signal userspace if we're not exiting with a core dump
> > -	 * or a killed vfork parent which shouldn't touch this mm.
> > +	 * because we want to leave the value intact for debugging
> > +	 * purposes.
> >  	 */
> >  	if (tsk->clear_child_tid) {
> >  		if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
> 
> Yes, thanks Michal!
> 
> Acked-by: Oleg Nesterov <oleg@redhat.com>

OK, thanks.
---

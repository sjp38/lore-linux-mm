Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6BD76B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 03:35:51 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v8so5560492wrd.21
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 00:35:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z37si1771543edd.59.2017.11.20.00.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 00:35:50 -0800 (PST)
Date: Mon, 20 Nov 2017 09:35:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Message-ID: <20171120083548.stupram6kpi5iu7i@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com>
 <20171103063544.13383-1-slandden@gmail.com>
 <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
 <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri 17-11-17 20:45:03, Shawn Landden wrote:
> On Fri, Nov 3, 2017 at 2:09 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 02-11-17 23:35:44, Shawn Landden wrote:
> > > It is common for services to be stateless around their main event loop.
> > > If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
> > > signals to the kernel that epoll_wait() and friends may not complete,
> > > and the kernel may send SIGKILL if resources get tight.
> > >
> > > See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
> > >
> > > Android uses this memory model for all programs, and having it in the
> > > kernel will enable integration with the page cache (not in this
> > > series).
> > >
> > > 16 bytes per process is kinda spendy, but I want to keep
> > > lru behavior, which mem_score_adj does not allow. When a supervisor,
> > > like Android's user input is keeping track this can be done in
> > user-space.
> > > It could be pulled out of task_struct if an cross-indexing additional
> > > red-black tree is added to support pid-based lookup.
> >
> > This is still an abuse and the patch is wrong. We really do have an API
> > to use I fail to see why you do not use it.
> >
> When I looked at wait_queue_head_t it was 20 byes.

I do not understand. What I meant to say is that we do have a proper
user api to hint OOM killer decisions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

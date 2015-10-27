Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D92882F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 11:43:44 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so123363590qkb.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 08:43:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j11si10371155qgj.128.2015.10.27.08.43.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 08:43:43 -0700 (PDT)
Date: Tue, 27 Oct 2015 11:43:42 -0400
From: Aristeu Rozanski <arozansk@redhat.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151027154341.GA14722@redhat.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
 <20151026172012.GC9779@dhcp22.suse.cz>
 <20151026174048.GP15046@redhat.com>
 <20151027080920.GA9891@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027080920.GA9891@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi Michal,
On Tue, Oct 27, 2015 at 09:09:21AM +0100, Michal Hocko wrote:
> On Mon 26-10-15 13:40:49, Aristeu Rozanski wrote:
> > Hi Michal,
> > On Mon, Oct 26, 2015 at 06:20:12PM +0100, Michal Hocko wrote:
> [...]
> > > Would it make more sense to distinguish different parts of the OOM
> > > report by loglevel properly?
> > > pr_err - killed task report
> > > pr_warning - oom invocation + memory info
> > > pr_notice - task list
> > > pr_info - stack trace
> > 
> > That'd work, yes, but I'd think the stack trace would be pr_debug. At a
> > point that you suspect the OOM killer isn't doing the right thing picking
> > up tasks and you need more information.
> 
> Stack trace should be independent on the oom victim selection because
> the selection should be as much deterministic as possible - so it should
> only depend on the memory consumption. I do agree that the exact trace
> is not very useful for the (maybe) majority of OOM reports. I am trying
> to remember when it was really useful the last time and have trouble to
> find an example. So I would tend to agree that pr_debug would me more
> suitable.

Only problem I see so far with this approach is that it'll require
reworing show_stack() on all architectures in order to be able to pass
and use log level and I'm wondering if it's something people will find
useful for other uses.

-- 
Aristeu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

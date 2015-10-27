Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 27F276B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:09:24 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so147913064wic.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 01:09:23 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id qp9si48514931wjc.189.2015.10.27.01.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 01:09:22 -0700 (PDT)
Received: by wikq8 with SMTP id q8so198996281wik.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 01:09:22 -0700 (PDT)
Date: Tue, 27 Oct 2015 09:09:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151027080920.GA9891@dhcp22.suse.cz>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
 <20151026172012.GC9779@dhcp22.suse.cz>
 <20151026174048.GP15046@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151026174048.GP15046@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <arozansk@redhat.com>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 26-10-15 13:40:49, Aristeu Rozanski wrote:
> Hi Michal,
> On Mon, Oct 26, 2015 at 06:20:12PM +0100, Michal Hocko wrote:
[...]
> > Would it make more sense to distinguish different parts of the OOM
> > report by loglevel properly?
> > pr_err - killed task report
> > pr_warning - oom invocation + memory info
> > pr_notice - task list
> > pr_info - stack trace
> 
> That'd work, yes, but I'd think the stack trace would be pr_debug. At a
> point that you suspect the OOM killer isn't doing the right thing picking
> up tasks and you need more information.

Stack trace should be independent on the oom victim selection because
the selection should be as much deterministic as possible - so it should
only depend on the memory consumption. I do agree that the exact trace
is not very useful for the (maybe) majority of OOM reports. I am trying
to remember when it was really useful the last time and have trouble to
find an example. So I would tend to agree that pr_debug would me more
suitable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 543686B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 08:19:36 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id tb5so45759561lbb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:19:36 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id o7si24156729wjr.71.2016.04.25.05.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 05:19:34 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id u206so124159844wme.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:19:34 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:19:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + procfs-expose-umask-in-proc-pid-status.patch added to -mm tree
Message-ID: <20160425121933.GG23933@dhcp22.suse.cz>
References: <571a8f8c.6RbLc3Gh9b0xGfe6%akpm@linux-foundation.org>
 <20160425093155.GD23933@dhcp22.suse.cz>
 <20160425121219.GQ11600@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425121219.GQ11600@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Richard W.M. Jones" <rjones@redhat.com>
Cc: akpm@linux-foundation.org, jmarchan@redhat.com, keescook@chromium.org, koct9i@gmail.com, pierre@spotify.com, tytso@mit.edu, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Mon 25-04-16 13:12:19, Richard W.M. Jones wrote:
> On Mon, Apr 25, 2016 at 11:31:55AM +0200, Michal Hocko wrote:
> > On Fri 22-04-16 13:54:36, Andrew Morton wrote:
> > > From: "Richard W.M. Jones" <rjones@redhat.com>
> > > Subject: procfs: expose umask in /proc/<PID>/status
> > > 
> > > It's not possible to read the process umask without also modifying it,
> > > which is what umask(2) does.  A library cannot read umask safely,
> > > especially if the main program might be multithreaded.
> > > 
> > > Add a new status line ("Umask") in /proc/<PID>/status.  It contains
> > > the file mode creation mask (umask) in octal.  It is only shown for
> > > tasks which have task->fs.
> > > 
> > > This patch is adapted from one originally written by Pierre Carrier.
> > > 
> > > 
> > > The use case is that we have endless trouble with people setting weird
> > > umask() values (usually on the grounds of "security"), and then everything
> > > breaking.  I'm on the hook to fix these.  We'd like to add debugging to
> > > our program so we can dump out the umask in debug reports.
> > > 
> > > Previous versions of the patch used a syscall so you could only read your
> > > own umask.  That's all I need.  However there was quite a lot of push-back
> > > from those, so this new version exports it in /proc.
> > > 
> > > See:
> > > 
> > 
> > lkmlo.org links tend to be rather unstable from my experience. Please
> > try to use lkml.kernel.org/[rg]/$msg_id as much as possible
> > 
> > > https://lkml.org/lkml/2016/4/13/704 [umask2]
> > 
> > http://lkml.kernel.org/r/1460574336-18930-1-git-send-email-rjones@redhat.com
> > 
> > > https://lkml.org/lkml/2016/4/13/487 [getumask]
> > 
> > http://lkml.kernel.org/r/1460547786-16766-1-git-send-email-rjones@redhat.com
> 
> FWIW this was heavily edited from my original commit message.  My
> original commit message (minus the Signed-off-by etc) was:
> 
>     procfs: expose umask in /proc/<PID>/status
>     
>     It's not possible to read the process umask without also modifying it,
>     which is what umask(2) does.  A library cannot read umask safely,
>     especially if the main program might be multithreaded.
>     
>     Add a new status line ("Umask") in /proc/<PID>/status.  It contains
>     the file mode creation mask (umask) in octal.  It is only shown for
>     tasks which have task->fs.
>     
>     This patch is adapted from one originally written by Pierre Carrier.

I guess Andrew added the remaining and I agree that part is really
useful. Any API to the userspace should document the use case. We have
added just way too many of those in the past without proper
justification. It is hard (close to impossible for some) to find out
what was the original reason why they were introduce and whether a small
change might break anything. Reference to discussions which shape the
API is useful as well.

Just my 2c
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 773126B026D
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:36:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h1so16096635wre.0
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:36:31 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id g3si626997edd.382.2018.04.17.07.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:36:30 -0700 (PDT)
Date: Tue, 17 Apr 2018 16:36:23 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417143623.GA11772@kroah.com>
References: <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
 <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com>
 <20180417110717.GB17484@dhcp22.suse.cz>
 <20180417140434.GU2341@sasha-vm>
 <20180417101502.3f61d958@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417101502.3f61d958@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Jiri Kosina <jikos@kernel.org>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 10:15:02AM -0400, Steven Rostedt wrote:
> On Tue, 17 Apr 2018 14:04:36 +0000
> Sasha Levin <Alexander.Levin@microsoft.com> wrote:
> 
> > The solution to this, in my opinion, is to automate the whole selection
> > and review process. We do selection using AI, and we run every possible
> > test that's relevant to that subsystem.
> > 
> > At which point, the amount of work a human needs to do to review a patch
> > shrinks into something far more managable for some maintainers.
> 
> I guess the real question is, who are the stable kernels for? Is it just
> a place to look at to see what distros should think about. A superset
> of what distros would take. Then distros would have a nice place to
> look to find what patches they should look at. But the stable tree
> itself wont be used. But it's not being used today by major distros
> (Red Hat and SuSE). Debian may be using it, but that's because the
> stable maintainer for its kernels is also the Debian maintainer.
> 
> Who are the customers of the stable trees? They are the ones that
> should be determining the "equation" for what goes into it.

The "customers" of the stable trees are anyone who uses Linux.

Right now, it's estimated that only about 1/3 of the kernels running out
there, at the best, are an "enterprise" kernel/distro.  2/3 of the world
either run a kernel.org-based release + their own patches, or Debian.
And Debian piggy-backs on the stable kernel releases pretty regularily.

So the majority of the Linux users out there are what we are doing this
for.  Those that do not pay for a company to sift through things and
only cherry-pick what they want to pick out (hint, they almost always
miss things, some do this better than others...)

That's who this is all for, which is why we are doing our best to keep
on top of the avalanche of patches going into upstream to get the needed
fixes (both security and "normal" fixes) out to users as soon as
possible.

So again, if you are a subsystem maintainer, tag your patches for
stable.  If you do not, you will get automated emails asking you about
patches that should be applied (like the one that started this thread).
If you want to just have us ignore your subsystem entirely, we will be
glad to do so, and we will tell the world to not use your subsystem if
at all possible (see previous comments about xfs, and I would argue IB
right now...)

> Personally, I use stable as a one off from mainline. Like I mentioned
> in another email. I'm currently on 4.15.x and will probably move to
> 4.16.x next. Unless there's some critical bug announcement, I update my
> machines once a month. I originally just used mainline, but that was a
> bit too unstable for my work machines ;-)

That's great, you are a user of these trees then.  So you benifit
directly, along with everyone else who relies on them.

And again, I'm working with the SoC vendors to directly incorporate
these trees into their device trees, and I've already seen some devices
in the wild push out updated 4.4.y kernels a few weeks after they are
released.  That's the end goal here, to have the world's devices in a
much more secure and stable shape by relying on these kernels.

thanks,

greg k-h

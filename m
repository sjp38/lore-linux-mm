Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F20B6B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:46:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27so15434089wre.23
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 03:46:45 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id u8si6414639edp.400.2018.04.17.03.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 03:46:43 -0700 (PDT)
Date: Tue, 17 Apr 2018 12:46:37 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417104637.GD8445@kroah.com>
References: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416170010.GA11034@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 07:00:10PM +0200, Pavel Machek wrote:
> Hi!
> 
> > >> Let me ask my wife (who is happy using Linux as a regular desktop user)
> > >> how comfortable she would be with triaging kernel bugs...
> > >
> > >That's really up to the distribution, not the main kernel stable. Does
> > >she download and compile the kernels herself? Does she use LEDs?
> > >
> > >The point is, stable is to keep what was working continued working.
> > >If we don't care about introducing a regression, and just want to keep
> > >regressions the same as mainline, why not just go to mainline? That way
> > >you can also get the new features? Mainline already has the mantra to
> > >not break user space. When I work on new features, I sometimes stumble
> > >on bugs with the current features. And some of those fixes require a
> > >rewrite. It was "good enough" before, but every so often could cause a
> > >bug that the new feature would trigger more often. Do we back port that
> > >rewrite? Do we backport fixes to old code that are more likely to be
> > >triggered by new features?
> > >
> > >Ideally, we should be working on getting to no regressions to stable.
> > 
> > This is exactly what we're doing.
> > 
> > If a fix for a bug in -stable introduces a different regression,
> > should we take it or not?
> 
> If a fix for bug introduces regression, would you call it "obviously
> correct"?

I honestly can't believe you all are arguing about this.  We backport
bugfixes to the stable tree.  If those fixes also are buggy we either
apply the fix for that problem that ended up in Linus's tree, or we
revert the patch.  If the fix is not in Linus's tree, sometimes we leave
the "bug" in stable for a bit to apply some pressure on the
developer/maintainer to get it fixed in Linus's tree (that's what I mean
by being "bug compatible".)

This is exactly what we have been doing for over a decade now, why are
people suddenly getting upset?

Oh, I know why, suddenly subsystems that never were taking the time to
mark patches for stable are getting patches backported and are getting
nervous.  The simple way to stop that from happening is to PROPERLY MARK
PATCHES FOR STABLE IN THE FIRST PLACE!

If you do that, then, no "automated" patches will get selected as you
already handled them all.  Or if there are some automated patches
picked, you can easily NAK them (like xfs does as they know better than
everyone else, and honestly, I trust them, and don't run xfs myself), or
do like what I do when it happens to me and go "hey, nice, I missed that
one!"

There, problem solved, if you do that, no more worrying by you at all,
and this thread can properly die.

ugh,

greg k-h

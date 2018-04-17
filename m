Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8466B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:50:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b10so4490668wrf.3
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 03:50:57 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id i26si3438241eda.318.2018.04.17.03.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 03:50:56 -0700 (PDT)
Date: Tue, 17 Apr 2018 12:50:49 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417105049.GE8445@kroah.com>
References: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416162850.GA7553@amd>
 <20180416163917.GE2341@sasha-vm>
 <20180416164230.GA9807@amd>
 <20180416164514.GG2341@sasha-vm>
 <20180416165451.GB9807@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416165451.GB9807@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 06:54:51PM +0200, Pavel Machek wrote:
> On Mon 2018-04-16 16:45:16, Sasha Levin wrote:
> > On Mon, Apr 16, 2018 at 06:42:30PM +0200, Pavel Machek wrote:
> > >On Mon 2018-04-16 16:39:20, Sasha Levin wrote:
> > >> On Mon, Apr 16, 2018 at 06:28:50PM +0200, Pavel Machek wrote:
> > >> >
> > >> >> >> Is there a reason not to take LED fixes if they fix a bug and don't
> > >> >> >> cause a regression? Sure, we can draw some arbitrary line, maybe
> > >> >> >> designate some subsystems that are more "important" than others, but
> > >> >> >> what's the point?
> > >> >> >
> > >> >> >There's a tradeoff.
> > >> >> >
> > >> >> >You want to fix serious bugs in stable, and you really don't want
> > >> >> >regressions in stable. And ... stable not having 1000s of patches
> > >> >> >would be nice, too.
> > >> >>
> > >> >> I don't think we should use a number cap here, but rather look at the
> > >> >> regression rate: how many patches broke something?
> > >> >>
> > >> >> Since the rate we're seeing now with AUTOSEL is similar to what we were
> > >> >> seeing before AUTOSEL, what's the problem it's causing?
> > >> >
> > >> >Regression rate should not be the only criteria.
> > >> >
> > >> >More patches mean bigger chance customer's patches will have a
> > >> >conflict with something in -stable, for example.
> > >>
> > >> Out of tree patches can't be a consideration here. There are no
> > >> guarantees for out of tree code, ever.
> > >
> > >Out of tree code is not consideration for mainline, agreed. Stable
> > >should be different.
> > 
> > This is a discussion we could have with in right forum, but FYI stable
> > doesn't even guarantee KABI compatibility between minor versions at this
> > point.
> 
> Stable should be useful base for distributions. They carry out of tree
> patches, and yes, you should try to make their lives easy.

How do you know I already don't do that?

But no, in the end, it's not my job to make their life easier if they
are off in their own corner never providing me feedback or help.  For
those companies/distros/SoCs that do provide that feedback, I am glad to
work with them.

As proof of that, there are at least 3 "major" SoC vendors that have
been merging every one of the stable releases into their internal trees
for the past 6+ months now.  I get reports when they do the merge and
test, and so far, we have only had 1 regression.  And that regression
was because that SoC vendor forgot to upstream a patch that they had in
their internal tree (i.e. they fixed it a while ago but forgot to tell
anyone else, nothing we can do about that.)

So if you are a distro/company/whatever that takes stable releases, and
have run into problems, please let me know, and I will be glad to work
with you.

If you are not that, then please don't attempt to speak for them...

thanks,

greg k-h

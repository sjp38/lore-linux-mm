Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A4C406B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:58:46 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2014928dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 09:58:45 -0700 (PDT)
Date: Wed, 27 Jun 2012 09:58:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120627165841.GH15811@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626220809.GA4653@tiehlicka.suse.cz>
 <20120626221452.GA15811@google.com>
 <4FEAC9CB.2010800@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEAC9CB.2010800@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

Hello, Glauber.

On Wed, Jun 27, 2012 at 12:52:27PM +0400, Glauber Costa wrote:
> >Just disallow clearing .use_hierarchy if it was mounted with the
> >option?  We can later either make the file RO 1 for compatibility's
> >sake or remove it.
> 
> How will it buy us anything, if it is clear by default??

With the mount option specified, why would it be clear by default?

> The problem is that we may differ in what means "default behavior".
> 
> It is very clear in a system call, API, or any documented feature.
> We never made the guarantee, *ever*, that non-hierarchical might be
> the default.
> 
> I understand that users may have grown accustomed to it. But users
> grow accustomed to bugs as well! Bugs change behaviors. In fact, in
> hardware emulation - where it matters, because it is harder to
> change it - we have emulator people actually emulating bugs -
> because that is what software expects.
> 
> Is this reason for us to keep bugs around, because people grew
> accustomed to it? Hell no. Well, it might be: If we have a proven
> user base that is big and solid on top of that, it may be fair to
> say: "Well, this is unfortunate, but this is how it plays".

You're just playing with semantics now.  Hey, who guarantees anything?
I don't find anything inscribed in stone or with hundred goverment
stamps which legally forbids me from "rm -rf"ing the whole cgroup.

Gees...  If we've shipped kernel versions with certain major behavior
for years, that frigging is the guarantee we've been making to the
userland.

Of course, nothing is absolute and everything is subject to trade off,
but, come on, we're talking about major SILENT behavior switch.  No,
nobody gets away with that.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

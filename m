Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FAA2C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F6152087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:19:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F6152087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3D018E0005; Thu, 31 Jan 2019 17:19:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEB7D8E0001; Thu, 31 Jan 2019 17:19:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B4298E0005; Thu, 31 Jan 2019 17:19:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 510B08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 17:19:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so3692373pfi.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:19:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oG98hRE8n6vf71726B5V4eey/UclKwj77NtGutyq5xw=;
        b=rYJ2LS3N7fK3+lKbIx9dhceMykhZML99jE0ft2mpMrynHd5BKZ9iMAdJmEpypghZNG
         wtC9rz6uHhcqUn33wfEEb9LSf7G8PBu+bke1e8IEvgGsBWXz7T0r8oOzLSjI9d0SllSv
         CzKaiXqsyCFuEDizuERgbS35wT6oPUOnnupa0KsA4MqcBUCz+xEMBJ62hwUUg4zJYH44
         zXK7ONZmt1eAq9FmFg3N6ub3bfrXeD2uw2+yU2Hb3WsEoVfTW34n0sITKpaP2JmKFxy8
         iSXF5dkjQ1WWCP1cwmRN6hm++tamcD+N5ApPST2Vcxd3grSbiYM9694sFL8EJ2CKtdMj
         GjAw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukfngQLUUX/bLPRPk6nkQEDxtqE8fTfNC4vWNm8aUvtXWwMFAmux
	NLN6KdzVu4eJVLNk9w85Y40eNMRpvHERiqA1vVdnQuApSuQG2+RGT92Ln1LG3L66NFUuSjx5OQV
	tOSfX5AsT4e+jcYCBSmF9JU8bBhuUeCXnlKGo8VjYZ5XayP5w70JvDAsqkpo0pik=
X-Received: by 2002:a63:de46:: with SMTP id y6mr33064475pgi.198.1548973148892;
        Thu, 31 Jan 2019 14:19:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4rCjK58ZA1gXOCeqNrR13joKVhFdHVTlo2op5EoPKkAJITVfU0q7rf2K9vPu093LX4Sxon
X-Received: by 2002:a63:de46:: with SMTP id y6mr33064418pgi.198.1548973147652;
        Thu, 31 Jan 2019 14:19:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548973147; cv=none;
        d=google.com; s=arc-20160816;
        b=aImeZVWA02ScGflDsrKykQ7ihaqqrJAbHSw8j0tPoRKgc8TWKWa16NXBZxHSrHGuKG
         mgMOWu59qeOyiLd4LKt9HelH/YKGaWqWe0uyl40vu8tVf8egDW51mj27Aps9/54eWLhG
         K6eqIPyqAAnSCf6/vT2zoOcGczjN2tWnjb1yZOA7jjyNL0FUW0s69deKKnIqt3B4Zpuq
         hKjpZTI8t0S5JyBTYg7gYv3DvRZFSGtPRndWcOt17L0knx0W5MdiHnsVhuDshXRb0Wu3
         71mlQRG8PWzMTiZfEZT9P3TRIQ+QVzREyLqHD2DVj0GtTHYVIAYIQ0ZCqSrUt9E4u/dS
         rqew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oG98hRE8n6vf71726B5V4eey/UclKwj77NtGutyq5xw=;
        b=srlcVhxrsPSUsxhKsG1ajcJ7Jwgz70Hg+LOkBb4GYRCiOtAu4Zutsja+eSk96L7xFf
         WrtWMGX84cyI9ZywJOVf2f40yX68TgP9E4gtY10jypaldd+D55KfnQyPRhmZ9riEscyM
         4NjNNnlK0mnSYQNdRmhBMY2r28BK5oHdlXMkShzXqbRWm8wmcVpjgWY+0A9/slCvSvbz
         XduxaUIha2Z9+4wX1jbcqEoSCJDvhxd9ZLb8JXtu1SAzKk6BHtmFNJpb0y3f958HuQO6
         yMhJqqDhkkQPLkyJUEXsfdjlg4+D+PJAa/Dfvwsfk1oHE9CDm9wUocbYe81x6Z8C9nNg
         ayzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id g12si5445646pgd.567.2019.01.31.14.19.06
        for <linux-mm@kvack.org>;
        Thu, 31 Jan 2019 14:19:07 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 01 Feb 2019 08:49:05 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gpKfo-0003GY-55; Fri, 01 Feb 2019 09:19:04 +1100
Date: Fri, 1 Feb 2019 09:19:04 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190131221904.GL4205@dastard>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131185704.GA8755@castle.DHCP.thefacebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 06:57:10PM +0000, Roman Gushchin wrote:
> On Thu, Jan 31, 2019 at 10:10:11AM +0100, Michal Hocko wrote:
> > On Thu 31-01-19 12:34:03, Dave Chinner wrote:
> > > On Wed, Jan 30, 2019 at 12:21:07PM +0000, Chris Mason wrote:
> > > > 
> > > > 
> > > > On 29 Jan 2019, at 23:17, Dave Chinner wrote:
> > > > 
> > > > > From: Dave Chinner <dchinner@redhat.com>
> > > > >
> > > > > This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.
> > > > >
> > > > > This change causes serious changes to page cache and inode cache
> > > > > behaviour and balance, resulting in major performance regressions
> > > > > when combining worklaods such as large file copies and kernel
> > > > > compiles.
> > > > >
> > > > > https://bugzilla.kernel.org/show_bug.cgi?id=202441
> > > > 
> > > > I'm a little confused by the latest comment in the bz:
> > > > 
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=202441#c24
> > > 
> > > Which says the first patch that changed the shrinker behaviour is
> > > the underlying cause of the regression.
> > > 
> > > > Are these reverts sufficient?
> > > 
> > > I think so.
> > > 
> > > > Roman beat me to suggesting Rik's followup.  We hit a different problem 
> > > > in prod with small slabs, and have a lot of instrumentation on Rik's 
> > > > code helping.
> > > 
> > > I think that's just another nasty, expedient hack that doesn't solve
> > > the underlying problem. Solving the underlying problem does not
> > > require changing core reclaim algorithms and upsetting a page
> > > reclaim/shrinker balance that has been stable and worked well for
> > > just about everyone for years.
> > 
> > I tend to agree with Dave here. Slab pressure balancing is quite subtle
> > and easy to get wrong. If we want to plug the problem with offline
> > memcgs then the fix should be targeted at that problem. So maybe we want
> > to emulate high pressure on offline memcgs only. There might be other
> > issues to resolve for small caches but let's start with something more
> > targeted first please.
> 
> First, the path proposed by Dave is not regression-safe too. A slab object
> can be used by other cgroups as well, so creating an artificial pressure on
> the dying cgroup might perfectly affect the rest of the system.

Isolating regressions to the memcg dying path is far better than the
current changes you've made, which have already been *proven* to
affect the rest of the system.

> We do reparent
> slab lists on offlining, so there is even no easy way to iterate over them.
> Also, creating an artifical pressure will create unnecessary CPU load.

Yes, so do your changes - they increase small slab scanning by 100x
which means reclaim CPU has most definitely increased.

However, the memcg reaper *doesn't need to be perfect* to solve the
"takes too long to clean up dying memcgs". Even if it leaves shared
objects behind (which we want to do!), it still trims those memcgs
down to /just the shared objects still in use/.  And given that
objects shared by memcgs are in the minority (according to past
discussions about the difficulies of accounting them correctly) I
think this is just fine.

Besides, those reamining shared objects are the ones we want to
naturally age out under memory pressure, but otherwise the memcgs
will have been shaken clean of all other objects accounted to them.
i.e. the "dying memcg" memory footprint goes down massively and the
"long term buildup" of dying memcgs basically goes away.

> So I'd really prefer to make the "natural" memory pressure to be applied
> in a way, that doesn't leave any stalled objects behind.

Except that "natural" memory pressure isn't enough to do this, so
you've artificially inflated that "natural" pressure and screwed up
the reclaim for everyone else.

> Second, the code around slab pressure is not "worked well for years": as I can
> see the latest major change was made about a year ago by Josef Bacik
> (9092c71bb724 "mm: use sc->priority for slab shrink targets").

Strawman. False equivalence.

The commit you mention was effectively a minor tweak - instead of
using the ratio of pages scanned to pages reclaimed to define the
amount of slab work, (a second order measure of reclaim urgency), it
was changed to use the primary reclaim urgency directive that the
page scanning uses - the reclaim priority.

This *isn't a major change* in algorithm - it conveys essentially
exactly the same information, and does not change the overall page
cache vs shrinker reclaim balance. It just behaves more correctly in
corner cases where there is very little page cache/lots of slab and
vice versa.  It barely even changed the amount or balance of
reclaim being done under normal circumstances.

> The existing balance, even if it works perfectly for some cases, isn't something
> set in stone. We're really under-scanning small cgroups, and I strongly believe
> that what Rik is proposing is a right thing to do.

You keep saying "small cgroups". That is incorrect.

The shrinker knows nothing about the size of the cache. All it knows
is how many /freeable objects/ are in the cache. A large cache can
have zero freeable objects, and to the shrinker look just like a
small cache with just a few freeable objects. You're trying to
derive cache characterisations from accounting data that carries no
such information.

IOWs, adding yet another broken, racy, unpredictable "deferred scan
count" to triggers when there is few freeable objects in the cache
is not an improvement. The code is completely buggy, because
shrinkers can run in parallel and so shrinker->small_scan can be
modified by multiple shrinker instances running at the same time.
That's the problem the shrinker->nr_deferred[] array and the atomic
exchanges solve (which has other problems we really need to fix
before we even start thinking about changing shrinker balances at
all).

> If we don't scan objects
> in small cgroups unless we have really strong memory pressure, we're basically
> wasting memory.

Maybe for memcgs, but that's exactly the oppose of what we want to
do for global caches (e.g. filesystem metadata caches). We need to
make sure that a single, heavily pressured cache doesn't evict small
caches that lower pressure but are equally important for
performance.

e.g. I've noticed recently a significant increase in RMW cycles in
XFS inode cache writeback during various benchmarks. It hasn't
affected performance because the machine has IO and CPU to burn, but
on slower machines and storage, it will have a major impact.

The reason these RMW cycles occur is that the dirty inode in memory
needs to be flushed to the backing buffer before it can be written.
That backing buffer is in a metadata slab cache controlled by a
shrinker (not the superblock shrinker which reclaims inodes).  It's
*much smaller* than the inode cache, but it also needs to be turned
over much more slowly than the inode cache. If it gets turned over
too quickly because of inode cache pressure, then flushing dirty
inodes (in the superblock inode cache shrinker!) needs to read the
backing buffer back in to memory before it can write the inode and
reclaim it.

And when you change the shrinker infrastructure to reclaim small
caches more aggressively? It changes the balance of cache reclaim
within the filesystem, and so opens up these "should have been in
the cache but wasn't" performance problems. Where are all the
problems that users have reported? In the superblock shrinker,
reclaiming XFS inodes, waiting on IO to be done on really slow Io
subsystems. Basically, we're stuck because the shrinker changes have
screwed up the intra-cache reclaim balance.

IOWs, there's complex dependencies between shrinkers and memory
reclaim, and changing the balance of large vs small caches can have
very adverse affects when memory pressure occurs. For XFS,
increasing small cache pressure vs large cache pressure has the
effect of *increasing the memory demand* of inode reclaim because
writeback has to allocate buffers, and that's one of the reasons
it's the canary for naive memory reclaim algorithm changes.

Just because something "works for your memcg heavy workload" doesn't
mean it works for everyone, or is even a desirable algorithmic
change.

> And it really makes no sense to reclaim inodes with tons of attached pagecache
> as easy as "empty" inodes.

You didn't even know this happened until recently. Have you looked
up it's history?  e.g. from the initial git commit in 2.6.12, almost
15 years ago now, there's this comment on prune_icache():

 * Any inodes which are pinned purely because of attached pagecache have their
 * pagecache removed.  We expect the final iput() on that inode to add it to
 * the front of the inode_unused list.  So look for it there and if the
 * inode is still freeable, proceed.  The right inode is found 99.9% of the
 * time in testing on a 4-way.

Indeed, did you know this inode cache based page reclaim is what
PGINODESTEAL and KSWAPD_INODESTEAL /proc/vmstat record for us? e.g.
looking at my workstation:

$ grep inodesteal /proc/vmstat
pginodesteal 14617964
kswapd_inodesteal 6674859
$

Page cache reclaim from clean, unreferenced, aged-out inodes
actually happens an awful lot in real life.

> So, assuming all this, can we, please, first check if Rik's patch is addressing
> the regression?

Nope, it's broken and buggy, and reintroduces problems with racing
deferred counts that were fixed years ago when I originally
wrote the numa aware shrinker infrastructure.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2F0DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:33:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 659DF21773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:33:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 659DF21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 030A48E0003; Tue, 19 Feb 2019 23:33:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23138E0002; Tue, 19 Feb 2019 23:33:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC3B08E0003; Tue, 19 Feb 2019 23:33:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD4C68E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 23:33:46 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id d134so1545840qkc.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:33:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=StqX4vTxF6oIn78jh7pzc2MrCGJV+926WhCu9FYXIxk=;
        b=sCqYeTZ5nDySfQrwkYVjM955m950nFXibxacsKaaQ5x+gSeq+GAdz8WtHjgyNp4LUc
         pHteM+AQBiy9UzR8qV7PqICQ2OzhxIGHgv1AkVaqmVmzn15SnFfZWBlkwyXlzatfAFxU
         2Oi/fNms+ojRob7DFpuuzSz0/Txk9I7IroE2hJuYn32y8B8whmgIIFS5JGEXd/Wmxke4
         bftHef4YAQKgilEl4i3f0yXqH/bB4EqnCv9Lr2FZ+E4tznQy2OOYoTt7InC2qf49TOvo
         8rvg/wSKl8iXgELmZdbYhwgB1+9fEd8RP2iAOU+mcLQ13rcgQD0pFv38GYCfWb3qDbPw
         UBfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZQ1QhkzhaG+LhBcVBsAdzsD+5GuGBsAuN0vRO3AIqxiQjD6Gkx
	He80GAwrnWPH6bNwVIz34bMxp5RpBz9Y63DSBYxWdCsdf1fA1e39r7jHnQ7F340Q61yFxqo07Ao
	PoXWW44GVj3sc2qio6C9wctwlCJUZB1s8yTbaSTbZYm2M/BYrT9VbYpeD41eORysX4A==
X-Received: by 2002:a37:9a13:: with SMTP id c19mr19590820qke.48.1550637226400;
        Tue, 19 Feb 2019 20:33:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZLxK0HBkv/xNlUREW7YDPHECfONWaO/39LSZ8PlV/j25lRd7zB/0ucodFK4lTqwQu/WaoZ
X-Received: by 2002:a37:9a13:: with SMTP id c19mr19590785qke.48.1550637225431;
        Tue, 19 Feb 2019 20:33:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550637225; cv=none;
        d=google.com; s=arc-20160816;
        b=FDxjmU8/cisgTGdbRJItDeKbN7Bjir3TWX4Z5joBUTu0CbP/8iTIwFxtMYuPYMJ1DJ
         rMCcTxMLjNVgV4miQrpjaU1ouud3wNbTPbpuU3VeL4t3T5nvDRle6lxtl3WLDQnYjSs2
         cYlHMayfD/WmKCFaEkjHCqztp1HWz++7mCDlnxjMwEnRHdQmLxof6/3LzLsfgHWSg6qV
         7AAt9TRh2UInoSvFzBmjqxDkN2LJVQ8ZWBT/CD4eLkC5Uf2oAXJKkJEm9/F163cpoI3c
         dVF4TfYz0DJr0UfjaxsxZkzJhlM4l3GFaTyxbiRqNKD+7JMMJM6m0ri/wJUwbadyr6xI
         1G1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=StqX4vTxF6oIn78jh7pzc2MrCGJV+926WhCu9FYXIxk=;
        b=rzhAbsbqchSsFpTZ4G+cJarzyOpayowUnODuG08Y0vuwP75LRIFXL6ywLGeMnqJAGN
         cprRJ2XELIyZbWKPF+Rupc+vw4ZFqn6bNMWE9NS0rC9FnpPKG0YiigHw5rhvqjzYM3CH
         BeKThXpJzPBYi/st19HdZJAbgeT6FDKx+muJoL/fXsJkG3pyYBV82QDASy0DrBFskZf7
         dirpGi4hNFKqW6fykuuc1Dy8S2ILoywDkc38EIHkOeOWcRVCPXNGhcIPQVIgZmaDBXux
         vSYlXHEJqkf5gDVrdyrHzV5p6BBv9PhKphCXRJzlVcSsneuViiiGdO4NypTd8Ju4KDXi
         35+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si7647533qtn.351.2019.02.19.20.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 20:33:45 -0800 (PST)
Received-SPF: pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D938B89AC6;
	Wed, 20 Feb 2019 04:33:43 +0000 (UTC)
Received: from rh (ovpn-116-82.phx2.redhat.com [10.3.116.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EFE175D6AA;
	Wed, 20 Feb 2019 04:33:42 +0000 (UTC)
Received: from [::1] (helo=rh)
	by rh with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <dchinner@redhat.com>)
	id 1gwJZg-0005pP-BB; Wed, 20 Feb 2019 15:33:36 +1100
Date: Wed, 20 Feb 2019 15:33:32 +1100
From: Dave Chinner <dchinner@redhat.com>
To: Rik van Riel <riel@surriel.com>
Cc: Roman Gushchin <guro@fb.com>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190220043332.GA31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
 <20190219020448.GY31397@rh>
 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
 <20190219232627.GZ31397@rh>
 <9446a6a8a6d60cf5727d348d34969ba1e67e1c58.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9446a6a8a6d60cf5727d348d34969ba1e67e1c58.camel@surriel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 20 Feb 2019 04:33:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 09:06:07PM -0500, Rik van Riel wrote:
> On Wed, 2019-02-20 at 10:26 +1100, Dave Chinner wrote:
> > On Tue, Feb 19, 2019 at 12:31:10PM -0500, Rik van Riel wrote:
> > > On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> > > > On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > > > > Sorry, resending with the fixed to/cc list. Please, ignore the
> > > > > first letter.
> > > > 
> > > > Please resend again with linux-fsdevel on the cc list, because
> > > > this
> > > > isn't a MM topic given the regressions from the shrinker patches
> > > > have all been on the filesystem side of the shrinkers....
> > > 
> > > It looks like there are two separate things going on here.
> > > 
> > > The first are an MM issues, one of potentially leaking memory
> > > by not scanning slabs with few items on them,
> > 
> > We don't leak memory. Slabs with very few freeable items on them
> > just don't get scanned when there is only light memory pressure.
> > That's /by design/ and it is behaviour we've tried hard over many
> > years to preserve. Once memory pressure ramps up, they'll be
> > scanned just like all the other slabs.
> 
> That may have been fine before cgroups, but when
> a system can have (tens of) thousands of slab
> caches, we DO want to scan slab caches with few
> freeable items in them.
> 
> The threshold for "few items" is 4096, not some
> actually tiny number. That can add up to a lot
> of memory if a system has hundreds of cgroups.

That doesn't sound right. The threshold is supposed to be low single
digits based on the amount of pressure on the page cache, and it's
accumulated by deferral until the batch threshold (128) is exceeded.

Ohhhhh. The penny just dropped - this whole sorry saga has be
triggered because people are chasing a regression nobody has
recognised as a regression because they don't actually understand
how the shrinker algorithms are /supposed/ to work.

And I'm betting that it's been caused by some other recent FB
shrinker change.....

Yup, there it is:

commit 9092c71bb724dba2ecba849eae69e5c9d39bd3d2
Author: Josef Bacik <jbacik@fb.com>
Date:   Wed Jan 31 16:16:26 2018 -0800

    mm: use sc->priority for slab shrink targets

....
    We don't need to know exactly how many pages each shrinker represents,
    it's objects are all the information we need.  Making this change allows
    us to place an appropriate amount of pressure on the shrinker pools for
    their relative size.
....

-       delta = (4 * nr_scanned) / shrinker->seeks;
-       delta *= freeable;
-       do_div(delta, nr_eligible + 1);
+       delta = freeable >> priority;
+       delta *= 4;
+       do_div(delta, shrinker->seeks);


So, prior to this change:

	delta ~= (4 * nr_scanned * freeable) / nr_eligible

IOWs, the ratio of nr_scanned:nr_eligible determined the resolution
of scan, and that meant delta could (and did!) have values in the
single digit range.

The current code introduced by the above patch does:

	delta ~= (freeable >> priority) * 4

Which, as you state, has a threshold of freeable > 4096 to trigger
scanning under low memory pressure.

So, that's the original regression that people are trying to fix
(root cause analysis FTW).  It was introduced in 4.16-rc1. The
attempts to fix this regression (i.e. the lack of low free object
shrinker scanning) were introduced into 4.18-rc1, which caused even
worse regressions and lead us directly to this point.

Ok, now I see where the real problem people are chasing is, I'll go
write a patch to fix it.

> Roman's patch, which reclaimed small slabs extra
> aggressively, introduced issues, but reclaiming
> small slabs at the same pressure/object as large
> slabs seems like the desired behavior.

It's still broken. Both of your patches do the wrong thing because
they don't address the resolution and accumulation regression and
instead add another layer of heuristics over the top of the delta
calculation to hide the lack of resolution.

> > That's a cgroup referencing and teardown problem, not a memory
> > reclaim algorithm problem. To treat it as a memory reclaim problem
> > smears memcg internal implementation bogosities all over the
> > independent reclaim infrastructure. It violates the concepts of
> > isolation, modularity, independence, abstraction layering, etc.
> 
> You are overlooking the fact that an inode loaded
> into memory by one cgroup (which is getting torn
> down) may be in active use by processes in other
> cgroups.

No I am not. I am fully aware of this problem (have been since memcg
day one because of the list_lru tracking issues Glauba and I had to
sort out when we first realised shared inodes could occur). Sharing
inodes across cgroups also causes "complexity" in things like cgroup
writeback control (which cgroup dirty list tracks and does writeback
of shared inodes?) and so on. Shared inodes across cgroups are
considered the exception rather than the rule, and they are treated
in many places with algorithms that assert "this is rare, if it's
common we're going to be in trouble"....

> > > The second is the filesystem (and maybe other) shrinker
> > > functions' behavior being somewhat fragile and depending
> > > on closely on current MM behavior, potentially up to
> > > and including MM bugs.
> > > 
> > > The lack of a contract between the MM and the shrinker
> > > callbacks is a recurring issue, and something we may
> > > want to discuss in a joint session.
> > > 
> > > Some reflections on the shrinker/MM interaction:
> > > - Since all memory (in a zone) could potentially be in
> > >   shrinker pools, shrinkers MUST eventually free some
> > >   memory.
> > 
> > Which they cannot guarantee because all the objects they track may
> > be in use. As such, shrinkers have never been asked to guarantee
> > that they can free memory - they've only ever been asked to scan a
> > number of objects and attempt to free those it can during the scan.
> 
> Shrinkers may not be able to free memory NOW, and that
> is ok, but shrinkers need to guarantee that they can
> free memory eventually.

If the memory the shrinker tracks is in use, they can't free
anything. Hence there is no guarantee a shrinker can free anything
from it's cache now or in the future. i.e. it can return freeable =
0 as much as it wants, and the memory reclaim infrastructure just
has to deal with the fact it can't free any memory.

This is where page reclaim would trigger the OOM killer, but that
still won't guarantee a shrinker can free anything.......

> > > - The MM should be able to deal with shrinkers doing
> > >   nothing at this call, but having some work pending 
> > >   (eg. waiting on IO completion), without getting a false
> > >   OOM kill. How can we do this best?
> > 
> > By integrating shrinkers into the same feedback loops as page
> > reclaim. i.e. to allow individual shrinker instance state to be
> > visible to the backoff/congestion decisions that the main page
> > reclaim loops make.
> > 
> > i.e. the problem here is that shrinkers only feedback to the main
> > loop is "how many pages were freed" as a whole. They aren't seen as
> > individual reclaim instances like zones for apge reclaim, they are
> > just a huge amorphous blob that "frees some pages". i.e. They sit off
> > to
> > the side and run their own game between main loop scans and have no
> > capability to run individual backoffs, schedule kswapd to do future
> > work, don't have watermarks to provide reclaim goals, can't
> > communicate progress to the main control algorithm, etc.
> > 
> > IOWs, the first step we need to take here is to get rid of
> > the shrink_slab() abstraction and make shrinkers a first class
> > reclaim citizen....
> 
> I completely agree with that. The main reclaim loop
> should be able to make decisions like "there is plenty
> of IO in flight already, I should wait for some to
> complete instead of starting more", which requires the
> kind of visibility you have outlined.
> 
> I guess we should find some whiteboard time at LSF/MM
> to work out the details, after we have a general discussion
> on this in one of the sessions.

I won't be at LSFMM. The location is absolutely awful in terms of
travel - ~6 days travel time for a 3 day conference is just not
worthwhile.

> Given the need for things like lockless data structures
> in some subsystems, I imagine we would want to do a lot
> of the work here with callbacks, rather than standardized
> data structures.

Just another ops structure.... :P

> > > - Related to the above: stalling in the shrinker code is
> > >   unpredictable, and can take an arbitrarily long amount
> > >   of time. Is there a better way we can make reclaimers
> > >   wait for in-flight work to be completed?
> > 
> > Look at it this way: what do you need to do to implement the main
> > zone reclaim loops as individual shrinker instances? Complex
> > shrinker implementations have to deal with all the same issues as
> > the page reclaim loops (including managing cross-cache dependencies
> > and balancing). If we can't answer this question, then we can't
> > answer the questions that are being asked.
> > 
> > So, at this point, I have to ask: if we need the same functionality
> > for both page reclaim and shrinkers, then why shouldn't the goal be
> > to make page reclaim just another set of opaque shrinker
> > implementations?
> 
> I suspect each LRU could be implemented as a shrinker
> today, with some combination of function pointers and
> data pointers (in case of LRUs, to the lruvec) as control
> data structures.
.....
> The logic of which cgroups we should reclaim memory from
> right now, and which we should skip for now, is already
> handled outside of the code that calls both the LRU and
> the slab shrinking code.
> 
> In short, I see no real obstacle to unifying the two.

Neither do I, except that it's a huge amount of work and there's no
guarantee we'll be able to make any better than what we have now....

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com


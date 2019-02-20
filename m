Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A00D5C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53EF72146F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:47:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53EF72146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFE1A8E0003; Tue, 19 Feb 2019 21:47:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAFC58E0002; Tue, 19 Feb 2019 21:47:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9D968E0003; Tue, 19 Feb 2019 21:47:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 985928E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:47:28 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t1so1775451plo.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:47:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=n5cNIIdpJQZZLTtkresoNTM1yUQaK9aX8XarVlSWpQg=;
        b=mtPz4sXN7EhV4kN/Z/jRxhuiUh3RovGmja3ELJ1Hv03c3dIihe8raDf06Q7IHK3okJ
         jXIcbOVGk8SpV29pAtpb7HjeuxJXkeb/oukvRblxmN09NqHE1/zJ7GHh60G2efiX/2dk
         /RnQWzCN599fYsDatEAQHW1HC6EXwc9ciYj0bGZbit810VvBUa8oJMRbVpVNdU7WbA2g
         ZFmpUlchM2sT3iZ5lmK/IOVY5Ko7nfBrTn+Nx0LPU0N+5QEduqSAdgCJlHf10tXhuZ8J
         ChVD9gNiqA568Q0VVbTH9+7+s++H4IfQPn7/9UWeNfVS43rxgl8r7QOAs1xFSO9bg/ss
         bOnQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuaNZGtXjCWckLt9YxNlJ66du0LHHw3udRODDKEVLx8OIIbCjpPI
	Z39Uf8ENHxwRePNJ1HFQ9GU4+wD8qMYMnh9YarIa4tdPJlsQ6JraIJDcmobj0USV0nrG7jTkyWm
	9+to3RKht/ksmJs41Kj8FUzlZn4MQyCCrS8r7aMuNyxD3sSoyhg1gSHBSn2ji/Uc=
X-Received: by 2002:a62:33c1:: with SMTP id z184mr32380717pfz.104.1550630848209;
        Tue, 19 Feb 2019 18:47:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbI7jUR5wmTY8CAEZfU58dQ2G9dCz9gdwgn2YkyD6oxkgAxkL5G9BFfeZoZb5x65dXGd9G+
X-Received: by 2002:a62:33c1:: with SMTP id z184mr32380649pfz.104.1550630847003;
        Tue, 19 Feb 2019 18:47:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550630846; cv=none;
        d=google.com; s=arc-20160816;
        b=eRGVsLGDZdDDpDfvaVY8d6nKORUwFlvyCilaR81FlD1P3FIhS5QoGAre+CdE5/cuXB
         lUEsJy3KoRGWC4mjiEpaJ4hJ4Il+ZogeOjAso4QJy83XUoh/QLOYqUL15W3KoAQ+n4Dg
         HzTmmTBh6zXCpC7IILCwykVBybtnz0uS0DDvTtzbLHrvCbb6O0wG6HSacBh7WiHUz96p
         wDXMMpa+NJVcC7MSF2pNX9eMqELQ96+Ecxq7RpraMEsvOjsBWA+leJDTyrMP/ECVCU98
         LglRKn4Ofcn/lF/ZsA0gVD7WoLzgUNpEGu1DWrASRWH+2E0Px3B03RDpgixHeB31M/Ic
         I2Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=n5cNIIdpJQZZLTtkresoNTM1yUQaK9aX8XarVlSWpQg=;
        b=I8BvB4jBKWUBFZPG5nmSVC6+MGj96EUJdpXB4ija3omQ3aV/x012taewQo9Cpf1rZg
         Ww8rH20M5roQnNJ5AlVrOD3/1Cu1Pf3NE9O5Ioh+uwJ4hU6ypEHxf4GZA2H36dacA+c5
         l7a7sZ5esVSQYpOaoaqOey0JgQgBlMRISwzU82HX+xhYl31WAwkjFquRp2u1z8EAOtyq
         iIz2OBOhScL9vWJ+AH7bqjd0EebqGOMjACYdfeMtpoij6M4R2H5Iq/JrTLySqdCnu15P
         tHUS4B8kR3z119+5YYxLBTNYT0c57XqsAQv9RN1shuJjquB6Y1y8LWQDFaePudsPQknb
         AzEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id i33si18437238pld.329.2019.02.19.18.47.25
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 18:47:26 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.136;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail01.adl6.internode.on.net with ESMTP; 20 Feb 2019 13:17:24 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gwHut-0005t2-Pn; Wed, 20 Feb 2019 13:47:23 +1100
Date: Wed, 20 Feb 2019 13:47:23 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190220024723.GA20682@dastard>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 07:13:33AM +0000, Roman Gushchin wrote:
> Sorry, once more, now with fsdevel@ in cc, asked by Dave.
> --
> 
> Recent reverts of memcg leak fixes [1, 2] reintroduced the problem
> with accumulating of dying memory cgroups. This is a serious problem:
> on most of our machines we've seen thousands on dying cgroups, and
> the corresponding memory footprint was measured in hundreds of megabytes.
> The problem was also independently discovered by other companies.
> 
> The fixes were reverted due to xfs regression investigated by Dave Chinner.

Context: it wasn't one regression that I investigated. We had
multiple bug reports with different regressions, and I saw evidence
on my own machines that something wasn't right because of the change
in the IO patterns in certain benchmarks. Some of the problems were
caused by the first patch, some were caused by the second patch.

This also affects ext4 (i.e. it's a general problem, not an XFS
problem) as has been reported a couple of times, including this one
overnight:

https://lore.kernel.org/lkml/4113759.4IQ3NfHFaI@stwm.de/

> Simultaneously we've seen a very small (0.18%) cpu regression on some hosts,
> which caused Rik van Riel to propose a patch [3], which aimed to fix the
> regression. The idea is to accumulate small memory pressure and apply it
> periodically, so that we don't overscan small shrinker lists. According
> to Jan Kara's data [4], Rik's patch partially fixed the regression,
> but not entirely.

Rik's patch was buggy and made an invalid assumptions about how a
cache with a small number of freeable objects is a "small cache", so
any comaprisons made with it are essentially worthless.

More details about the problems with the patch and approach here:

https://lore.kernel.org/stable/20190131224905.GN31397@rh/

> The path forward isn't entirely clear now, and the status quo isn't acceptable
> due to memcg leak bug. Dave and Michal's position is to focus on dying memory
> cgroup case and apply some artificial memory pressure on corresponding slabs
> (probably, during cgroup deletion process). This approach can theoretically
> be less harmful for the subtle scanning balance, and not cause any regressions.

I outlined the dying memcg problem in patch[0] of the revert series:

https://lore.kernel.org/linux-mm/20190130041707.27750-1-david@fromorbit.com/

It basically documents the solution I proposed for dying memcg
cleanup:

dgc> e.g. add a garbage collector via a background workqueue that sits on
dgc> the dying memcg calling something like:
dgc> 
dgc> void drop_slab_memcg(struct mem_cgroup *dying_memcg)
dgc> {
dgc>         unsigned long freed;
dgc> 
dgc>         do {
dgc>                 struct mem_cgroup *memcg = NULL;
dgc> 
dgc>                 freed = 0;
dgc>                 memcg = mem_cgroup_iter(dying_memcg, NULL, NULL);
dgc>                 do {
dgc>                         freed += shrink_slab_memcg(GFP_KERNEL, 0, memcg, 0);
dgc>                 } while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
dgc>         } while (freed > 0);
dgc> }

This is a pretty trivial piece of code and doesn't requiring
changing the core memory reclaim code at all.

> In my opinion, it's not necessarily true. Slab objects can be shared between
> cgroups, and often can't be reclaimed on cgroup removal without an impact on the
> rest of the system.

I've already pointed out that it is preferable for shared objects
to stay in cache, not face expedited reclaim:

https://lore.kernel.org/linux-mm/20190131221904.GL4205@dastard/

dgc> However, the memcg reaper *doesn't need to be perfect* to solve the
dgc> "takes too long to clean up dying memcgs". Even if it leaves shared
dgc> objects behind (which we want to do!), it still trims those memcgs
dgc> down to /just the shared objects still in use/.  And given that
dgc> objects shared by memcgs are in the minority (according to past
dgc> discussions about the difficulies of accounting them correctly) I
dgc> think this is just fine.
dgc> 
dgc> Besides, those reamining shared objects are the ones we want to
dgc> naturally age out under memory pressure, but otherwise the memcgs
dgc> will have been shaken clean of all other objects accounted to them.
dgc> i.e. the "dying memcg" memory footprint goes down massively and the
dgc> "long term buildup" of dying memcgs basically goes away.

This all seems like pretty desirable cross-memcg working set
maintenance behaviour to me...

> Applying constant artificial memory pressure precisely only
> on objects accounted to dying cgroups is challenging and will likely
> cause a quite significant overhead.

I don't know where you got that from - the above example is clearly
a once-off cleanup.

And executing it via a workqueue in the async memcg cleanup path
(which already runs through multiple work queues to run and wait for
different stages of cleanup) is not complex or challenging, nor is
it likely to add additional overhead because it means we will avoid
the long term shrinker scanning overhead that cleanup currently
requires.

> Also, by "forgetting" of some slab objects
> under light or even moderate memory pressure, we're wasting memory, which can be
> used for something useful.

Cached memory is not "forgotten" or "wasted memory". If the scan is
too small and not used, it is deferred to the next shrinker
invocation. This batching behaviour is intentionally done for scan
efficiency purposes. Don't take my word for it, read the discussion
that went along with commit 0b1fb40a3b12 ("mm: vmscan: shrink all
slab objects if tight on memory")

https://lore.kernel.org/lkml/20140115012541.ad302526.akpm@linux-foundation.org/

From Andrew:

akpm> Actually, the intent of batching is to limit the number of calls to
akpm> ->scan().  At least, that was the intent when I wrote it!  This is a
akpm> good principle and we should keep doing it.  If we're going to send the
akpm> CPU away to tread on a pile of cold cachelines, we should make sure
akpm> that it does a good amount of work while it's there.

IOWs, the "small scan" proposals defeat existing shrinker efficiency
optimisations. This change in behaviour is where the CPU usage
regressions in "small cache" scanning comes from.  As Andrew said:
scan batching is a good principle and we should keep doing it.

> Dying cgroups are just making this problem more
> obvious because of their size.

Dying cgroups see this as a problem only because they have extremely
poor life cycle management. Expediting dying memcg cache cleanup is
the way to fix this and that does not need us to change global memory
reclaim behaviour.

> So, using "natural" memory pressure in a way, that all slabs objects are scanned
> periodically, seems to me as the best solution. The devil is in details, and how
> to do it without causing any regressions, is an open question now.
> 
> Also, completely re-parenting slabs to parent cgroup (not only shrinker lists)
> is a potential option to consider.

That should be done once the memcg gc thread has shrunk the caches
down to just the shared objects (which we want to keep in cache!)
that reference the dying memcg. That will get rid of all the
remaining references and allow the memcg to be reclaimed completely.

> It will be nice to discuss the problem on LSF/MM, agree on general path and
> make a potential list of benchmarks, which can be used to prove the solution.

In reality, it comes down to this - should we:

	a) add a small amount of code into the subsystem to perform
	expedited reaping of subsystem owned objects and test against
	the known, specific reproducing workload; or

	b) change global memory reclaim algorithms in a way that
	affects every linux machine and workload in some way,
	resulting in us having to revalidate and rebalance memory
	reclaim for a large number of common workloads across all
	filesystems and subsystems that use shrinkers, on a wide
	range of different storage hardware and on both headless and
	desktop machines.

And when we look at it this way, if we end up with option b) as the
preferred solution then we've well and truly jumped the shark.  The
validation effort required for option b) is way out of proportion
with the small niche of machines and environments affected by the
dying memcg problem and the risk of regressions for users outside
these memcg-heavy environments is extremely high (as has already
been proven).

Cheers,

Dave
-- 
Dave Chinner
david@fromorbit.com


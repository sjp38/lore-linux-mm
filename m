Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B785C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 362992146F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:06:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 362992146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC46B8E0003; Tue, 19 Feb 2019 21:06:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B078E0002; Tue, 19 Feb 2019 21:06:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EB768E0003; Tue, 19 Feb 2019 21:06:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 709588E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:06:15 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id y31so21950593qty.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:06:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=VJvwrT+xn3fMhdgfv0OyUHRsUvcrhqE+k+u7XZDLpvo=;
        b=Qn5ukX0fdc/ycFe0dl6zoq+PaYNS/Nmj/aSn0TqzgOVwazf4gL63BMCvadH5fBrm8+
         dnWx8nWFkKd72DpSjlEfVcBUCqfTgz1ts9aIGVjyYOOvAuBEMw0DA+rfhB2pLThHGAHu
         +/GP3kAe3o6iM+jkm8ou1PNLZjQ5oqApQ/2l0irIzz2PvoRdo/tgv+KIASW4BrFRgiSG
         oq+vg8gPgioo/d+H+xjORlm7MqOp+0uja5GYRWJMpWwJHkaRyyVbdyntyyj61Hp2/viP
         DabK74z44kQD5pqnFuvmwkmOeitMEOgenWraCr7VK4wOLZgUHG8KaJzBeqyrBQUHfzUU
         G3Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAuZhRIj2U9iCag4yKw1IyM3jYmjpox+ZD34e4ts8+m3edfKDDYL5
	6w8W2pEVROYfioEQwObjUqx3ZeqiAUrvTXb1rIN9P+kbrffREJ7tftasw9IvpsIjvc6Dw6PuRef
	P5RKJJ369QAbbWVrCSbQ4vRoLlpFEq9OdxR+9PvjrTvPDOZXW35hRV02AWNjdb0L+jA==
X-Received: by 2002:a37:4f45:: with SMTP id d66mr23217419qkb.81.1550628375171;
        Tue, 19 Feb 2019 18:06:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSUG/G479ixSsMcXigjWjYOvfr8OcuQ0ZbjuPILjH4RtVGVkXVVESQOcQ7oBmVItgKYBbi
X-Received: by 2002:a37:4f45:: with SMTP id d66mr23217384qkb.81.1550628374636;
        Tue, 19 Feb 2019 18:06:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550628374; cv=none;
        d=google.com; s=arc-20160816;
        b=ZS6rJfhaJEC2rIMZIWzE1kWJTYl5GH+ilB+xi5ym2G/jbIk07bIt55WElMEpygZEd5
         UTDseQcrPTOVsJ7YaLcwSuaObmsyVb+CX+QZpVzcCM35Y7wVag1QE7pav2etBgoMCKI8
         6plHWSWrHPYEkrFkrRpWAWwtbDoO2NBtEUdTjqK0lnEMy6SqyMDbS4PkxlveZbyI88VW
         76SZ+V653Bin2pWAOLURt5Q3Ljc6MDc/q5j8gUUZO/q/wHPToH7vaGkwVqOyLeVQT9rc
         7m86Amkqa80V0NXOMwHWKb4cQk/KvPYI6trNoIyDuJi6cGQFDCA0srRjh7ZJUmyekiVy
         oKPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=VJvwrT+xn3fMhdgfv0OyUHRsUvcrhqE+k+u7XZDLpvo=;
        b=kF3jjhy21kKeyXZ1xtDlc48jyNJxH6irxMlmE62pnw99sUvy1R0/lwg5GssTX5KO56
         gmfnnzydnaCsfDeeF5tUVv6hgL4ciktMbt2LPT3bNwu4/Wjs+b9nfjZ3mKLdDjtkB18x
         dNiYPuPyA+tOKOjRpQcGF5DCE5xs8aetddZyl7o54n8ScxaTQSQKjSV7CqMb1sXRDjhV
         GzYmNsorJ/Fe4sdmpL9nSVxbIPlwegp+B7d+YL3VXY9aLNVX5sgY3o61DjC4M4VR6v/a
         2nHVNZHNum+FX4gdZA/Fdu+rWq1Q8RlMjOvq9WoK5++CoS2btgqtYbZcDI+jR8Il37rI
         KadA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id t76si11378636qke.94.2019.02.19.18.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 18:06:13 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gwHGx-0000Ri-OD; Tue, 19 Feb 2019 21:06:07 -0500
Message-ID: <9446a6a8a6d60cf5727d348d34969ba1e67e1c58.camel@surriel.com>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
From: Rik van Riel <riel@surriel.com>
To: Dave Chinner <dchinner@redhat.com>
Cc: Roman Gushchin <guro@fb.com>, "lsf-pc@lists.linux-foundation.org"
 <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,  "mhocko@kernel.org" <mhocko@kernel.org>,
 "guroan@gmail.com" <guroan@gmail.com>, Kernel Team <Kernel-team@fb.com>,
 "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Date: Tue, 19 Feb 2019 21:06:07 -0500
In-Reply-To: <20190219232627.GZ31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
	 <20190219020448.GY31397@rh>
	 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
	 <20190219232627.GZ31397@rh>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3y9U4uU8Te2RsBbMX8sv"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-3y9U4uU8Te2RsBbMX8sv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-20 at 10:26 +1100, Dave Chinner wrote:
> On Tue, Feb 19, 2019 at 12:31:10PM -0500, Rik van Riel wrote:
> > On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> > > On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > > > Sorry, resending with the fixed to/cc list. Please, ignore the
> > > > first letter.
> > >=20
> > > Please resend again with linux-fsdevel on the cc list, because
> > > this
> > > isn't a MM topic given the regressions from the shrinker patches
> > > have all been on the filesystem side of the shrinkers....
> >=20
> > It looks like there are two separate things going on here.
> >=20
> > The first are an MM issues, one of potentially leaking memory
> > by not scanning slabs with few items on them,
>=20
> We don't leak memory. Slabs with very few freeable items on them
> just don't get scanned when there is only light memory pressure.
> That's /by design/ and it is behaviour we've tried hard over many
> years to preserve. Once memory pressure ramps up, they'll be
> scanned just like all the other slabs.

That may have been fine before cgroups, but when
a system can have (tens of) thousands of slab
caches, we DO want to scan slab caches with few
freeable items in them.

The threshold for "few items" is 4096, not some
actually tiny number. That can add up to a lot
of memory if a system has hundreds of cgroups.

Roman's patch, which reclaimed small slabs extra
aggressively, introduced issues, but reclaiming
small slabs at the same pressure/object as large
slabs seems like the desired behavior.

Waiting until "memory pressure ramps up" is very
much the wrong thing to do, since reclaim priority
is not likely to drop to a small number until the
system is under so much memory pressure that the
workloads on the system suffer noticeable slowdowns.

> > and having
> > such slabs stay around forever after the cgroup they were
> > created for has disappeared,
>=20
> That's a cgroup referencing and teardown problem, not a memory
> reclaim algorithm problem. To treat it as a memory reclaim problem
> smears memcg internal implementation bogosities all over the
> independent reclaim infrastructure. It violates the concepts of
> isolation, modularity, independence, abstraction layering, etc.

You are overlooking the fact that an inode loaded
into memory by one cgroup (which is getting torn
down) may be in active use by processes in other
cgroups.

That may prevent us from tearing down all of a
cgroup's slab cache memory at cgroup destruction
time, which turns it into a reclaim problem.

> This all comes back to the fact that modifying the shrinker
> algorithms requires understanding what the shrinker implementations
> do and the constraints they operate under. It is not a "purely mm"
> discussion, and treating it as such results regressions like the
> ones we've recently seen.

That's fair, maybe both topics need to be discussed
in a shared MM/FS session, or even a plenary session.

> > The second is the filesystem (and maybe other) shrinker
> > functions' behavior being somewhat fragile and depending
> > on closely on current MM behavior, potentially up to
> > and including MM bugs.
> >=20
> > The lack of a contract between the MM and the shrinker
> > callbacks is a recurring issue, and something we may
> > want to discuss in a joint session.
> >=20
> > Some reflections on the shrinker/MM interaction:
> > - Since all memory (in a zone) could potentially be in
> >   shrinker pools, shrinkers MUST eventually free some
> >   memory.
>=20
> Which they cannot guarantee because all the objects they track may
> be in use. As such, shrinkers have never been asked to guarantee
> that they can free memory - they've only ever been asked to scan a
> number of objects and attempt to free those it can during the scan.

Shrinkers may not be able to free memory NOW, and that
is ok, but shrinkers need to guarantee that they can
free memory eventually.

Without that guarantee, it will be unsafe to ever place
a majority of system memory under the control of shrinker
functions, if only because the subsystems with those shrinker
functions tend to rely on the VM being able to free pages
when the pageout code is called.

> > - Shrinkers should not block kswapd from making progress.
> >   If kswapd got stuck in NFS inode writeback, and ended up
> >   not being able to free clean pages to receive network
> >   packets, that might cause a deadlock.
>=20
> Same can happen if kswapd got stuck on dirty page writeback from
> pageout(). i.e. pageout() can only run from kswapd and it issues IO,
> which can then block in the IO submission path waiting for IO to
> make progress, which may require substantial amounts of memory
> allocation.
>=20
> Yes, we can try to not block kswapd as much as possible just like
> page reclaim does, but the fact is kswapd is the only context where
> it is safe to do certain blocking operations to ensure memory
> reclaim can actually make progress.
>=20
> i.e. the rules for blocking kswapd need to be consistent across both
> page reclaim and shrinker reclaim, and right now page reclaim can
> and does block kswapd when it is necessary for forwards progress....

Agreed, the rules should be the same for both.

It would be good to come to some sort of agreement,
or even a wish list, on what they should be.

> > - The MM should be able to deal with shrinkers doing
> >   nothing at this call, but having some work pending=20
> >   (eg. waiting on IO completion), without getting a false
> >   OOM kill. How can we do this best?
>=20
> By integrating shrinkers into the same feedback loops as page
> reclaim. i.e. to allow individual shrinker instance state to be
> visible to the backoff/congestion decisions that the main page
> reclaim loops make.
>=20
> i.e. the problem here is that shrinkers only feedback to the main
> loop is "how many pages were freed" as a whole. They aren't seen as
> individual reclaim instances like zones for apge reclaim, they are
> just a huge amorphous blob that "frees some pages". i.e. They sit off
> to
> the side and run their own game between main loop scans and have no
> capability to run individual backoffs, schedule kswapd to do future
> work, don't have watermarks to provide reclaim goals, can't
> communicate progress to the main control algorithm, etc.
>=20
> IOWs, the first step we need to take here is to get rid of
> the shrink_slab() abstraction and make shrinkers a first class
> reclaim citizen....

I completely agree with that. The main reclaim loop
should be able to make decisions like "there is plenty
of IO in flight already, I should wait for some to
complete instead of starting more", which requires the
kind of visibility you have outlined.

I guess we should find some whiteboard time at LSF/MM
to work out the details, after we have a general discussion
on this in one of the sessions.

Given the need for things like lockless data structures
in some subsystems, I imagine we would want to do a lot
of the work here with callbacks, rather than standardized
data structures.

> > - Related to the above: stalling in the shrinker code is
> >   unpredictable, and can take an arbitrarily long amount
> >   of time. Is there a better way we can make reclaimers
> >   wait for in-flight work to be completed?
>=20
> Look at it this way: what do you need to do to implement the main
> zone reclaim loops as individual shrinker instances? Complex
> shrinker implementations have to deal with all the same issues as
> the page reclaim loops (including managing cross-cache dependencies
> and balancing). If we can't answer this question, then we can't
> answer the questions that are being asked.
>=20
> So, at this point, I have to ask: if we need the same functionality
> for both page reclaim and shrinkers, then why shouldn't the goal be
> to make page reclaim just another set of opaque shrinker
> implementations?

I suspect each LRU could be implemented as a shrinker
today, with some combination of function pointers and
data pointers (in case of LRUs, to the lruvec) as control
data structures.

Each shrinker would need some callbacks for things like
"lots of work is in flight already, wait instead of starting
more".

The magic of zone balancing could easily be hidden inside
the shrinker function for lruvecs. If a pgdat is balanced,
the shrinkers for each lruvec inside that pgdat could return
that no work is needed, while if work in only one or two
memory zones is needed, the shrinkers for those lruvecs would
do work, while the shrinkers would return "no work needed"
for the other lruvecs in the same pgdat.

The scan_control and shrink_control structs would probably
need to be merged, which is no obstacle at all.

The logic of which cgroups we should reclaim memory from
right now, and which we should skip for now, is already
handled outside of the code that calls both the LRU and
the slab shrinking code.

In short, I see no real obstacle to unifying the two.

--=20
All Rights Reversed.

--=-3y9U4uU8Te2RsBbMX8sv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxstg8ACgkQznnekoTE
3oM6DggArgkLuYQMg7xsHbsVrYu6CMniXBJlxdx9wePoBgKLtcRLZdbLahUPI3a4
X1xmEE33XvFwIT3k1T17DDN3DQLpoy0uaaJZuaC2UvaDylY0cZHbCtTByiSe4FHY
FwqO/9zEFO84uhfXa2GD5ws+c9nZbz1YqVGLtFNtlV8RMOZErpr52IM7DGROYZOp
WRaXpJbjVpZFr7gdBqyAO9VX2S327p2LBX7/KjQgJdE76JkZkgWGN9xd5pGtMsZT
cDdSQQogTnXpozMN5b7Cv9q6B1TtMz+4T7OPauYy/iYDW4TXkX7BC6GAmVfmsgui
4UuVEuic0QdZoXrV9YVEkj5t1qiiDA==
=yETr
-----END PGP SIGNATURE-----

--=-3y9U4uU8Te2RsBbMX8sv--


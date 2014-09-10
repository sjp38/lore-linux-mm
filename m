Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 113886B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 04:27:33 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so8043584pab.27
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:27:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t1si26740357pdi.123.2014.09.10.01.27.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 01:27:31 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:27:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers for
 scanner thread
Message-ID: <20140910082726.GO6758@twins.programming.kicks-ass.net>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
 <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
 <alpine.LSU.2.11.1408272258050.10518@eggly.anvils>
 <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils>
 <20140908093949.GZ6758@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9JPMzx+I1AXX4lYP"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>


--9JPMzx+I1AXX4lYP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 09, 2014 at 01:14:50PM -0700, Hugh Dickins wrote:
> > Quite horrible for sure. I really hate seeing KSM cruft all the way down
>=20
> Yes, I expected that, and I would certainly feel the same way.
>=20
> And even worse, imagine if this were successful, we might come along
> and ask to do something similar for khugepaged.  Though if it comes to
> that, I'm sure we would generalize into one hook which does not say
> "ksm" or "khugepaged" on it, but would still a present a single unlikely
> flag to be tested at this level.  Maybe you would even prefer the
> generalized version, but I don't want to complicate the prototype yet.
>=20
> If it weren't for the "we already have the mm cachelines here" argument,
> I by now feel fairly sure that I would be going for hooking into timer
> tick instead (where Thomas could then express his horror!).
>=20
> Do you think I should just forget about cacheline micro-optimizations
> and go in that direction instead?

Not really either I'm afraid. Slimming down the tick has been on my todo
list like forever. There's a lot of low hanging fruit there.

> > here. Can't we create a new (timer) infrastructure that does the right
> > thing? Surely this isn't the only such case.
>=20
> A sleep-walking timer, that goes to sleep in one bed, but may wake in
> another; and defers while beds are empty?  I'd be happy to try using
> that for KSM if it already existed, and no doubt Chintan would too
>=20
> But I don't think KSM presents a very good case for developing it.
> I think KSM's use of a sleep_millisecs timer is really just an apology
> for the amount of often wasted work that it does, and dates from before
> we niced it down 5.  I prefer the idea of a KSM which waits on activity
> amongst the restricted set of tasks it is tracking: as this patch tries.
>=20
> But my preference may be naive: doing lots of unnecessary work doesn't
> matter as much as waking cpus from deep sleep.

Ah yes, I see your point. So far the mentioned goal has been to not
unduly wake CPUs and waste energy, but your goal is better still. And
would indeed not be met by a globally deferred timer.

Does it make sense to drive both KSM and khugepage the same way we drive
the numa scanning? It has the benefit of getting rid of these threads,
which pushes the work into the right accountable context (the task its
doing the scanning for) and makes the scanning frequency depend on the
actual task activity.



--9JPMzx+I1AXX4lYP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJUEAtuAAoJEHZH4aRLwOS6begP/3j52bsmXzLcJJX5PEL3m7+X
dAp0iKHgwB/ou0QnDrg719UUzkf+dQDs+xQu7nwNi+FUaQ8nh9S7CsZQiAWFuAlf
lsgSH+OIcRKuz9j+jRfc5nzOSSz96mTVcty1BM5YQlpOWBr/mXfY8yCYbMYHsVWu
rRjYrwb8ZKn4Ry2DD5/5pzXRuS04xRgBgUh6oj0z6WO7RYn02VOlt0UAUDRXMkFJ
8+sbG5xHkVlHbxb8z4RuCBpK0kfknxyJKFhZ4M7kGkHiYuLgB/RUx5vx+VSuq0kC
S7Kd/MvpgV8z23nK9Zo64fo4OgIIVq0oR9v4OzN26EPqsAJTn1vyVjukBIn0XSy7
30ArG85kvF4mCXv1kenRoj/uDGwbL2nJ49Jf7Iu0Q6D8ByuiAW5snjNlJjg/rpLf
LEq8MICIrqg51pDsw4w0dXwuYr1q7OjLiUK3s72I1IG18Rmff631+XxETusqU+M8
zfyOgjLYB3kxgDg9Kv9xgEpQNAUMDdCH9Z1mpXZRf1u/QghpQegA8W3uf9/KEVTi
e+Tc0mBy71t/Q6vIP4L3h/1FyXi66L8VDshjHAl/yrqCdfihc+ptW/NJJpqGTz5M
USovWHNua/kprAXSjsD1oVGUHMpbzU+zlUT8HX6sJJYbhXE49aZKycAQY4lnmyRd
2WkpsZPiQzLQljYwoU/t
=nh8f
-----END PGP SIGNATURE-----

--9JPMzx+I1AXX4lYP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

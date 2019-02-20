Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5325C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 544E52086D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:49:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 544E52086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D77008E0021; Wed, 20 Feb 2019 10:49:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D27DC8E0002; Wed, 20 Feb 2019 10:49:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF0198E0021; Wed, 20 Feb 2019 10:49:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63E918E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:49:35 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a9so4692122edy.13
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:49:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=PJbCtLFtjD4MfYHOaSgBfDCfUxdJDemaYZos3O6Vnxo=;
        b=ZcLCxU9qIyGVqh9JwpMa9X5vt/SdRK8UTD0dweUD9Ihiy3k8spYBj1UZcJn4j9l/Y9
         BWTLIo1Ius8yFgvc49iA1iw+nVI7B0Ln/Y8oRxxV7++jBJ9LLiupTx4l8Aa9jYWo/zL5
         bZmJ781CgGw1TSKxwmfpcuzBAf8b4N0/x9YYMp1OCk7a7cOwmBiKKFW95RdSgTgHeDda
         /Eu3VLqqmLh27ZOyKHGUufBRR+/hnClj79llEXQ4totL/zGa6s/qJmeu1i+98yZ8rUx0
         oqVT+YppJlCeNweCx7eHgxmxJhZozWOxk6XocFP2hdtDV9XYivQuyFYTSLYy1CK/DIHm
         bARQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nstange@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nstange@suse.de
X-Gm-Message-State: AHQUAuaIiRjzhOLeXYbKFX6hSPZ8kFgC9Ff6QM5lwAsEk48UlD/mr9yk
	SMa8OjgXpWoP+4vIkDRlNsLmMcrF1aQcYphqfXOa03HsT94KwR3IS1WaEzSE5ew8Ig9F/yFOcaT
	jG+NctgUtfBFU750D5aQbjgOmJAB+x48IZX8IRECPxqZmJ8dZ9dERsuYZGQW2R5uG9w==
X-Received: by 2002:a17:906:e201:: with SMTP id gf1mr24541323ejb.10.1550677774753;
        Wed, 20 Feb 2019 07:49:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbbE9gfVfxbeJHYvsUA9XbOmV2z8xvd0PAtMpl3UIS4+oIkTPOCfnOOzSDy/G3mk/D7zZty
X-Received: by 2002:a17:906:e201:: with SMTP id gf1mr24541263ejb.10.1550677773131;
        Wed, 20 Feb 2019 07:49:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550677773; cv=none;
        d=google.com; s=arc-20160816;
        b=rEnvovuR9oTP480G3SU0ERp8dbv3ZwnfoGsjqmhtY9Z4nbb3C/w5IDOTFjuNa4+03u
         b62wAgL07u1kzsSaUg9wtEU5TeEpOH/blBnwQhAXAEmdBz2Lj4NCPklXyTA9uGdJKgvm
         Gkc952eqWqBdzyJZ3UcGBYFK4Qm6wmrM8Deil7kXsAahyYLvhmf1UBgDzvkAJZHzTIbm
         R098V4l3SzNpTihL2oeScq6vAtY9+PB6FK/IZjEkUvlv0c3kGGgDPRbWGYoZ8mV5/kqy
         tcAa33qXOqbflDQE7thkyJcp9UHCbM1rJNQpjbihBufctM1S/JG1mRnHMCyDzkKnmWWt
         UxVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id
         :in-reply-to:date:references:subject:cc:to:from;
        bh=PJbCtLFtjD4MfYHOaSgBfDCfUxdJDemaYZos3O6Vnxo=;
        b=xndO5MsSEaLOg6X0aVAOS1xIizZKPj0qrBWS0T2CGtsMTnFEcaeXH74TyqrfMrVJDq
         qoJDXCQ3NOVLHbAGvSzXA6Nvs/ocaSEA1iBfLgrs08VPaAPNZgg/DtFG53e0U9gGUdjo
         VtOFaj/mUGZ/BRnfTx4owBO+l/6t28KVpIQ+6GEgoRzGPy6CXCsuYyS5ufwQR0/6jorm
         eqhntoOI3Kst9YUr1GAzzJwzos+5N8z53IPteobzgXnph3p9RUkaCddZvwXo7p7QW1k+
         UHJBMtxYvluQfm3dVFlGLSRJGKUCD+wRUVkeOSi59IxnscUd0gNdjFGcSliPwgJ5j3F3
         DU5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nstange@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nstange@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y18si6170427edc.367.2019.02.20.07.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 07:49:33 -0800 (PST)
Received-SPF: pass (google.com: domain of nstange@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nstange@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nstange@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60097AF1E;
	Wed, 20 Feb 2019 15:49:32 +0000 (UTC)
From: Nicolai Stange <nstange@suse.de>
To: Nicolai Stange <nstange@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tejun Heo <tj@kernel.org>, Kevin Easton <kevin@guarana.org>, Cyril Hrubis <chrubis@suse.cz>, Daniel Gruss <daniel@gruss.cc>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>,  Jann Horn <jannh@google.com>,  Andrew Morton <akpm@linux-foundation.org>,  Greg KH <gregkh@linuxfoundation.org>,  Peter Zijlstra <peterz@infradead.org>,  Michal Hocko <mhocko@suse.com>,  Linux-MM <linux-mm@kvack.org>,  kernel list <linux-kernel@vger.kernel.org>,  Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <20190110004424.GH27534@dastard>
	<CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
	<20190110070355.GJ27534@dastard>
	<CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
	<20190110122442.GA21216@nautica>
	<CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
	<20190111020340.GM27534@dastard>
	<CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
	<20190111040434.GN27534@dastard>
	<CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
	<20190111073606.GP27534@dastard>
	<CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
Date: Wed, 20 Feb 2019 16:49:29 +0100
In-Reply-To: <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 11 Jan 2019 08:26:14 -0800")
Message-ID: <87imxejw8m.fsf@suse.de>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

<snip>

> So in order to use it as a signal, first you have to first scrub the
> cache (because if the page was already there, there's no signal at
> all), and then for the signal to be as useful as possible, you're also
> going to want to try to get out more than one bit of information: you
> are going to try to see the patterns and the timings of how it gets
> filled.
>
> And that's actually quite painful. You don't know the initial cache
> state, and you're not (in general) controlling the machine entirely,
> because there's also that actual other entity that you're trying to
> attack and see what it does.
>
> So what you want to do is basically to first make sure the cache is
> scrubbed (only for the pages you're interested in!), then trigger
> whatever behavior you are looking for, and then look how that affected
> the cache.
>
> In other words,  you want *multiple* residency status check - first to
> see what the cache state is (because you're going to want that for
> scrubbing), then to see that "yes, it's gone" when doing the
> scrubbing, and then to see the *pattern* and timings of how things are
> brought in.

<snap>

In an attempt to gain a better understanding of the guided eviction part
resp. the relevance of mincore() & friends to that, I worked on
reproducing the results from [1], section 6.1 ("Efficient Page Cache
Eviction on Linux").

In case anybody wants to run their own experiments: the sources can
be found at [2].

Disclaimer: I don't have access to the sources used by the [1]-paper's
authors nor do I know anything about their experimental setup. So it
might very well be the case, that my implementation is completely
different and/or inefficient.

Anyways, quoting from [1], section 6.1:

  "Eviction Set 1. These are pages already in the page cache,
   used by other processes. To keep them in the page cache,
   a thread continuously accesses these pages while also keep-
   ing the system load low by using sched yield and sleep.
   Consequently, they are among the most recently accessed
   pages of the system and eviction of these pages becomes
   highly unlikely."

I had two questions:
1.) Do the actual contents of "Eviction set 1" matter for the guided
    eviction's performance or can they as well be arbitrary but fixed?
    Because if the set's actual contents weren't of any importance,
    then mincore() would not be needed to initialize it with "pages
    already in the page cache".
2.) How does keeping some fixed set resident + doing some IO compare to
    simply streaming a huge random file through the page cache?

(To make it explicit: I didn't look into the probe part of the attack
 or the checking of the victim page's residency status as a
 termination condition for the eviction run.)

Obviously, there are two primary factors affecting the victim page
eviction performance: the file page cache size and disk read
bandwidth.

Naively speaking, I would suppose that keeping a certain set resident is
a cheap and stable way to constrain IO to the remaining portion of the
page cache and thus, reduce the amount of data required to be read from
disk until the victim page gets evicted.


Results summary (details can be found at the end of this mail):
- The baseline benchmark of simply streaming random data
  through the page cache behaves as expected:

    avg of "Inactive(file)" / avg of "victim page eviction time"

  yields ~480MB/s, which approx. matches my disk's read bandwidth
  (note: the victim page was mapped as !PROT_EXEC).

- I didn't do any sophisticated fine-tuning wrt. to parameters, but
  for the configuration yielding the best result, the average victim
  page eviction time was 147ms (stddev(*): 69ms, stderr: 1ms) with the
  "random but fixed resident set method". That's an improvement by a
  factor of 2.6 over the baseline "streaming random data method" (with
  the same amount of anonymous memory, i.e. "Eviction set 3",
  allocated: 7GB out of a total of 8GB).

- In principle, question 1.) can't be answered by experiment without
  controlling the initial, legitimate system workload. I did some lax
  tests on my desktop running firefox, libreoffice etc. though and of
  course, overall responsiveness got a lot better if the "Eviction set
  1" had been populated with pages already resident at the time the
  "attack" started. But the victim page eviction times didn't seem to
  improve -- at least not by factors such that my biased mind would
  have been able to recognize any change.

In conclusion, keeping an arbitrary, but fixed "Eviction set 1" resident
improved the victim page eviction performance by some factor over the
"streaming" baseline, where "Eviction set 1" was populated from a
single, attacker-controlled file and mincore() was not needed for
determining its initial contents.

To my surprise though, I needed to rely on mincore() at some other
place, namely *my* implementation of keeping the resident set
resident. My first naive approach was to have a single thread repeatedly
iterating over the pages and reading the first few bytes from each
through a mmapped area. That did not work out, because, even for smaller
resident sets of 1GB and if run with realtime priority, the accessing
thread would at some point in time encounter a reclaimed page and have
to wait for the page fault to get served. While waiting for that, even
more of the resident pages are likely to get reclaimed, causing
additional delays later on. Eventually, the resident page accessor
looses the game and will encounter page faults for almost the whole
resident set (which isn't resident anymore). I worked around this by
making the accessor thread check page residency via mincore(), touch
only the resident ones and queue the others to some refault ("rewarm")
thread. From briefly looking at iostat, this rewarmer thread actually
seemed to saturate the disk and thus, there was no need for additional
IO to put pressure on the page cache. For completeness, the amount of
pages from the resident set actually found resident made up for ~97% of
all file page cache pages (Inactive+Active(file)).

Note that the way mincore() is used here is different than for the
probe part of the attack: for probing, we'd like to know when a victim
page has been faulted in again, while the residency keeper needs to
check that some page has not been reclaimed before accessing
it. Furthermore, mincore() is run on pages from an attacker-controlled
and -owned file here. AFAICS, the patches currently under review
(c.f. [3]) don't mitigate against this latter abuse of mincore() & Co.

I personally doubt that doing something about it would be worth it
though: first of all, until proven otherwise, I'm assuming that the
improvement of the "resident set" based eviction method over the
"streaming" baseline is not by orders of magnitude and that the victim
page eviction times interesting to attackers (let's say better than
500ms) are achievable only under certain conditions: no swap and the
ability to block a large fraction of total memory with anonymous
mappings.

What's more, I can imagine that there are other ways to keep the
resident set resident without relying on mincore() at all: I haven't
tried it, but simply spawning a larger number of accessor threads, each
at a different position within "Eviction set 1", and hoping that most of
the time at least one of them finds a resident page to touch, might
work, too.


Thanks,

Nicolai


Experiment setup + numbers
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
My laptop has 8GB of RAM, a SSD and runs OpenSUSE 42.3 kernel package
version 4.4.165-81. I stopped almost all services, but didn't setup any
CPU isolation.

I ran 5 x 2 experiments where I allocated (and filled, of course)
3,4,5,6,7GB of anonymous memory each and compared the baseline
"read-in-a-huge-file" (mapped PROT_EXEC) results with the resident set
based eviction for each of these. While doing so, I continuously
measured eviction times of a !PROT_EXEC victim page and reported the
'Active(file)' + 'Inactive(file)' statistics from /proc/meminfo.


Baseline "streaming" benchmark results:

anon mem (GB):		7        6         5         4         3
Inactive(file) (MB):	189.3389  709.7063 1221.0910 1735.7510 2247.3340
eviction time (ms):	386.7712 1453.3975 2533.6084 3622.4995 4694.4668
quotient (MB/s):	489.5372  488.3085  481.9573  479.1584  478.7198

and, for comparison with the results from the resident set based eviction
below:
Inactive+Active(file) (MB):	358      1390      2415      3445      4469


Resident set based eviction:

For the results below, I chose to draw the resident set from a single
file filled with random data and made it total mem - allocated anon
mem in size. The disk bandwidth was saturated all the time.

anon mem (GB):			7        6        5         4         3
eviction time (ms):		146.6296 428.9594 620.2084  863.1423  977.8963
improvement over baseline:	2.6      3.4      4.1       4.2       4.8
Inactive+Active(file) (MB):	429      1449     2471      3494      4515
resident from res. set (MB):	417      1428     2426      3424      4429
fraction:			97.3%    98.6%    98.2%     98.0%     98.1%



[1] https://arxiv.org/abs/1901.01161 ("Page Cache Attacks")
[2] https://github.com/nicstange/pgc
[3] https://lkml.kernel.org/r/20190130124420.1834-1-vbabka@suse.cz
(*) The distribution of eviction times is not Gaussian.


--=20
SUSE Linux GmbH, GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton,
HRB 21284 (AG N=C3=BCrnberg)


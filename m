Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC88FC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:37:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96779208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:37:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96779208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20EF16B000D; Thu, 18 Jul 2019 04:37:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19B3A8E0001; Thu, 18 Jul 2019 04:37:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 061346B0010; Thu, 18 Jul 2019 04:37:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABA7F6B000D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:37:09 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u5so13321390wrp.10
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:37:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YRExWVxVQXKCddGNXA02R/5YuRZ/QpPzji6dJPwZbZA=;
        b=B+WfxAOgJxD3cqCMUderfWZsNzl8xj5s9cvP6gFLcsc6kCvESTznbirrCcurCA3Lly
         EjhmWgpStjyi+CYb+VZQLGtx2wyujIT97eWwXO8jbkcfRnAWKweTLdv7/SJa0eZxfGou
         A6EPBhq8LZT/kKwgCFriSB4y5ArFQ9fJC9D32tIVv7SllZmXOw06C1cck3DATQiP0biW
         kl+dH8q2vnSv0L5wGeCAAsExsNL5FToQB86O+oTVHPWdYmnJtDA3O8IEh5WWB0fcDHXx
         xYTcQ6ZFC/UoiCD0xj6LxQC8kCJEEGnzvLFBKzdYlTDY1YItBuURpXAIMSaHcX/lWl7C
         bIVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUPP/3jMUPs4qLpQAfjpiunx0HQvKX0S2eeXIKZh0L9prE/v2Om
	O7yHEDtY8Ea+6dCR90q9FQ9q7Ig/UMoEodgy629IjtjkKnEj37oPDsXeSK/ubkTlQY7uNHjFf0S
	4tboKtrQYhWy2ib3S9vCQvxsHjYpihM8NU30ml6OwPpuZ5hfjUZWKk6HIHCm3q87imw==
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr7595853wrm.265.1563439029196;
        Thu, 18 Jul 2019 01:37:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWAn+LY+eu5py6xgR4z/++5rQl60rU4tYhVvIgFEHOYz8ac4c1VKcpru1OEj6CWo3yxnsm
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr7595749wrm.265.1563439028187;
        Thu, 18 Jul 2019 01:37:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563439028; cv=none;
        d=google.com; s=arc-20160816;
        b=esFUuuMyKZ6YyqxHaMDxViKdHlQgoY+0cN+bclJiij/1l3itDzrau0muoK+LhBpSws
         mE9z+/HS3I4MrGlOTdb1B8ib7twxkWiw4sRk+ZiGwfY01fwGaIuo1MODHSPNPQxBAqVV
         Wr9Mevz/a+eK0hZzyPtYSdpfqyKHjLU2fR9f626sBIr7dLkXcVSQC1GjBlz9s9Vx6cQ3
         VPe0N6dzxJFPa32fcoDSbKAixjfqDhuqpGRBaSyNvxV0UCvw5iFSXZiRSX1Iu8oMNPUY
         RYBtvCkwP4x7pXreP1nfNUTn/3fQJBK2xnTL6ntnTuPThsrKJpyxFPRWF/J76Fm0JANx
         8FnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YRExWVxVQXKCddGNXA02R/5YuRZ/QpPzji6dJPwZbZA=;
        b=vtpd6Kw+EeJF9UDb8u94JS1dSCP326qI5BtKQhQTnJIsifug7mn+JPqqPmqFLYeE7F
         Or1HxKFctcqOQw1R8sY/zkLRmMpaxinPo6ynLrPczDpBUzfAAfssRUi+tKC1SJ7O7Na1
         7rcohUOxoB1cbi5ln0f9FW0leZtrJ4U5xvNt2xRhEyJ9WS0Tf/pto4KsC5CxSTdjzY0X
         UjQ1LeVJDT9rSwCuymdvhJLTm01EIlsrYsKEIIrCsnu/YcqZx52WPUDxL/AcebP0138J
         c5AdHldn9Srztmk/akb/iffx31AEEU+rMmNAeN/3ffwJm+Jy03Aw5TVLyBenWTzByaje
         js+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp15.blacknight.com (outbound-smtp15.blacknight.com. [46.22.139.232])
        by mx.google.com with ESMTPS id f124si21761388wmg.146.2019.07.18.01.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 01:37:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) client-ip=46.22.139.232;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp15.blacknight.com (Postfix) with ESMTPS id B98E61C22AB
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:37:07 +0100 (IST)
Received: (qmail 18201 invoked from network); 18 Jul 2019 08:37:07 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Jul 2019 08:37:07 -0000
Date: Thu, 18 Jul 2019 09:37:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <20190718083705.GD24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
 <20190716071121.GA24383@techsingularity.net>
 <xZGQeie9gbbIEm7ZciNh3PrdV8kTu-SE7KtUYV3cloMCUEdzB7taS5BcTzSUSaThu5_ftcRjr3sYcQB1c9dVPX3i1kQ2eP-xjKvFIpT7wZs=@protonmail.com>
 <20190717175332.GC24383@techsingularity.net>
 <8pZH2SJj3Wvi88hZae_hXIB29mCb8Pg9e5evGNd1xXYc9QlriA9xct5PgeQThRHe3Bll356k226z_VaEqosaSJUVydus09dsljaBtIpT7Bw=@protonmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8pZH2SJj3Wvi88hZae_hXIB29mCb8Pg9e5evGNd1xXYc9QlriA9xct5PgeQThRHe3Bll356k226z_VaEqosaSJUVydus09dsljaBtIpT7Bw=@protonmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 10:00:18PM +0000, howaboutsynergy@protonmail.com wrote:
> tl;dr: patch seems to work, thank you very much!
> 

\o/

> ????????????????????? Original Message ?????????????????????
> On Wednesday, July 17, 2019 7:53 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > Ok, great. From the trace, it was obvious that the scanner is making no
> > progress. I don't think zswap is involved as such but it may be making
> > it easier to trigger due to altering timing. At least, I see no reason
> > why zswap would materially affect the termination conditions.
>
> I don't know if it matters in this context, but I've been using the term
> `zswap`(somewhere else I think) to (wrongly)refer to swap in zram (and
> even sometimes called it ext4(in this bug report too) without realizing
> at the time that ext4 is only for /tmp and /var/tmp instead! they are
> ext4 in zram) but in fact this isn't zswap that I have been using (even
> though I have CONFIG_ZSWAP=y in .config) but it's just CONFIG_ZRAM=y with
> CONFIG_SWAP=y (and probably a bunch of others being needed too).

For other bugs, it would matter a lot. In this specific case, all that
was altered was the timing. With enough effort I was able to reproduce
the problem reliably within 30 minutes. With the patch, it ran without
hitting the problem for hours. I had tracing patches applied to log when
the specific problem occurred.

Without the patch, when the problem occurred, it hit 197009 times in a tight
loop driving up CPU usage. With the patch, the same condition was hit 4
times and in each case the task exited immediately as expected so I
think we're good.

> > a proper abort. I think it ends up looping in compaction instead of dying
> > without either aborting or progressing the scanner. It might explain why
> > stress-ng is hitting is as it is probably sending fatal signals on timeout
> > (I didn't check the source).
> Ah I didn't know there are multiple `stress` versions, here's what I used:
> 
> /usr/bin/stress is owned by stress 1.0.4-5
> 

Fortunately, they were all equivalent. The key was getting a task to
receive a fatal signal while compacting and while scanning a PFN that
was not aligned to SWAP_CLUSTER_MAX. Tricky to hit but fortunately your
test case was exactly what we needed.

> > <SNIP>
> 
> Now the "problem" is I can't tell if it would get stuck :D but it usually ends in no more than 17 sec:
> $ time stress -m 220 --vm-bytes 10000000000 --timeout 10
> stress: info: [7981] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
> stress: FAIL: [7981] (415) <-- worker 8202 got signal 9
> stress: WARN: [7981] (417) now reaping child worker processes
> stress: FAIL: [7981] (415) <-- worker 8199 got signal 9
> stress: WARN: [7981] (417) now reaping child worker processes
> stress: FAIL: [7981] (451) failed run completed in 18s
> 

That's fine. Fortunately my own debug tracing added based on your trace
gives me enough confidence.

> <SNIP>
>
> (probably irrelevant)Sometimes Xorg says it can't allocate any more memory but stacktrace looks like it's inside some zram i915 kernel stuff:
> 
> [ 1416.842931] [drm] Atomic update on pipe (A) took 188 us, max time under evasion is 100 us
> [ 1425.416979] Xorg: page allocation failure: order:0, mode:0x400d0(__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_RECLAIMABLE), nodemask=(null),cpuset=/,mems_allowed=0
> [ 1425.416984] CPU: 1 PID: 1024 Comm: Xorg Kdump: loaded Tainted: G     U            5.2.1-g527a3db363a3 #74
> [ 1425.416985] Hardware name: System manufacturer System Product Name/PRIME Z370-A, BIOS 2201 05/27/2019
> [ 1425.416986] Call Trace:

So this looks like the system is still under a lot of stress trying to
swap. It's unfortunate but unrelated and relatively benign given the
level of stress the system is under.

> <SNIP>
>
> But anyway, since last time I was able to trigger it with the normal(timeout 10) command on the third try, I've decided to keep trying that:
> after 170 more tries via `$ while true; do time stress -m 220 --vm-bytes 10000000000 --timeout 10; done`
> I saw no hangs or any runs taking more time than the usual 16-26 sec.
> So the patch must be working as intended. Thanks very much. Let me know if you want me to do anything else.
> 

Perfect. Thanks a million for your patience, testing and tracing (the
tracing pinpointed exactly where I needed to look -- of 3 potential
candidates, only one really made sense). I'll put a proper changelog on
this and send it out where it should get picked up for 5.3 and -stable.

-- 
Mel Gorman
SUSE Labs


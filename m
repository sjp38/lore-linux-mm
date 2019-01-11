Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 064CCC43444
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 22:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 987BF20878
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 22:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FEpu/iiL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 987BF20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF4588E0002; Fri, 11 Jan 2019 17:54:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7C798E0001; Fri, 11 Jan 2019 17:54:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D451A8E0002; Fri, 11 Jan 2019 17:54:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A316B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 17:54:45 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d73so8669919ywd.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:54:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zNLkCKY+SwAC6X03tE2DXpF/Ov1i3/WPtlft+zOut7Q=;
        b=BZj9MBq5XkqFBCtURu8fAIjNmnaHGRPTYLEhsKv0aCzmKzmtFm1PtDBoPtKFg6AZH8
         PLCcqfOlv0VVVxrbYkqOQtKibdm9SNbqAyNW78oiG4uYdOtPi79R2vbfub/ZiwC2g24y
         hYvmUet8SPujXLripNSU77Rldr5kVEZpf4gfkiINsHoymNrbPgee3J0Ld3iuyJPdcfet
         C4XqtYAFlkTj+q6M/c8kQlWw5f7KsqAl3ImAJwMPvWgB2ffCI4J7fI4GApWnf8X6Slsv
         Sm+4K/9IRTEZrzymZdh6sMee6YC49/CZJkFdGlLMikbpBjJcg5iMz9pG2N79RJOA94X3
         nROg==
X-Gm-Message-State: AJcUukeyMokSfP8oRuEv7nMXZXI0UEB6tmfFAxn2cth8gWnp7oihMEW7
	tgjJLD708YVUKzse79TfTW0TgCDAyFWQVLLlENBIEjKXvyJXk1QF1l9OUqBv//j//UG8AQfcQPE
	AHe12EcdGzmHKCESujm4CBpKAvHJb4wtSekySPuWfnq2SGssPEqR25aW9llfcu+n/U7Y3P1okbo
	NX72VVu7eqCf18ul3s1Uur64IEHIZGQvbB1oEKOmfLY9UGQ98MAIIKRICnkWhHv2dTk+Jxh/xbJ
	T0aNXa92UF46LAGH7TeTZnVvNd7YzMk7FPj469RAUuN9Kz9uiiRdi4xOVb5O75AC05OoKzOSJ05
	s4eZURbtrByYFgpnBIMDY9ROdrJWYVCu81fYJeiRc4w0bf9k9cmKuIJd+gCAL02hSxeUFUZIoTy
	V
X-Received: by 2002:a5b:acc:: with SMTP id a12mr15500252ybr.261.1547247285260;
        Fri, 11 Jan 2019 14:54:45 -0800 (PST)
X-Received: by 2002:a5b:acc:: with SMTP id a12mr15500221ybr.261.1547247284236;
        Fri, 11 Jan 2019 14:54:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547247284; cv=none;
        d=google.com; s=arc-20160816;
        b=s/bqeG6oNp2wa5OVP9ddJuVYrqW3wiR/oYMOP0VCxiHJukggxdky+FTzcFOKzj7+L7
         yLw1XoFIwhxq00wjSTqCpfnjZbkZ6KjsS/Q6rADIXZ71qRBevXTtFl8heIpF40cxYvny
         jDXXy9ukNrYN+7+pwfS+ZlRT4bVE4w6hWEpFvu7KmPpK8Ox9El06nLFhKC+fqbZX+06h
         SQ0YoybGQCwd9YhlNHwAtn/idM8UtlIWirLD5sss4AziHeMA649lGU2/szrO0m7Y9nZT
         ASJZS9pr0FqbA3GjMYrrm0wbGlBSKeSziqC6G64SNbhvdJwft1ciA/ItR95ZLe44MwuD
         KNnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zNLkCKY+SwAC6X03tE2DXpF/Ov1i3/WPtlft+zOut7Q=;
        b=yazAXnZW3SzL6DhFVwsoUFFfRVk3amyhJ5ekEt/ha8ELjM9CBjoY3tPe9ymdlcaYed
         QmgXqg/3oFC7KIqfLqtm+NQQTeQOYrVzz8gEZEmoQ6fvw/hcDejtKpSIu9QlMorGEWaC
         WVibt5VVBm3Oy7F8r7gzUdpCFaDZdLhZT8tGNDW7DLbuZJVncay+DlsmTuBNPD4JUe1o
         JXnaiC9VOPWRv/QRzpnFhI485rJYXfigtLGom7XSehbu8TFaE1wDpE/ADcxRcubLlEed
         +lEJloWL3A6AemaoKs5InMlSmwBVcqBo2vA5kK+oL2KfDzhNYemwCUgAvweTfxSHv99m
         jY0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="FEpu/iiL";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14sor21554560ybh.72.2019.01.11.14.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 14:54:44 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="FEpu/iiL";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zNLkCKY+SwAC6X03tE2DXpF/Ov1i3/WPtlft+zOut7Q=;
        b=FEpu/iiLCbxOefMnzM+e29eZKUax+WKTJ9cjl7jOddbTZebY2/SostcNctqDa4Dx1d
         6PVGqwf/eCG5vnokQvGr4clowLfbg9xLUZSMTuLRfbpPvCHlaY+r0yVqlebFpQBruaV6
         lpGG8ufiLq04g9gN1mr9xx3dGHW2oYOasQKFdaUk5gry9EnW89oel9439Cf4X2wo7fRV
         6SjB4/q2uvmLUY6xdEowY1v/MCl4iduT4Ws1P/pzxqenWqc/QYNbjXJpSLwcZsvrULgI
         gCwPzn2kRQKyMt4LWg8uPyulInvJ63418sXt8UOrwObgJNQlkxH8xLhrQ8iD4eGPD2cb
         wjSA==
X-Google-Smtp-Source: ALg8bN58sg1/k3eAFawuHi7YEe3TN+vxtPFSanna48jdOcq38wo8Sg27Eph82abwE/4dr65J2nl/OGgjza8a2AtX4xQ=
X-Received: by 2002:a25:2743:: with SMTP id n64mr959711ybn.164.1547247283381;
 Fri, 11 Jan 2019 14:54:43 -0800 (PST)
MIME-Version: 1.0
References: <20190110174432.82064-1-shakeelb@google.com> <20190111205948.GA4591@cmpxchg.org>
In-Reply-To: <20190111205948.GA4591@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 11 Jan 2019 14:54:32 -0800
Message-ID:
 <CALvZod7O2CJuhbuLUy9R-E4dTgL4WBg8CayW_AFnCCG6KCDjUA@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111225432.zWbzj0hxN5yVcEoc59e8Uyu38Sj3goL845MHlz5vwOA@z>

Hi Johannes,

On Fri, Jan 11, 2019 at 12:59 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Hi Shakeel,
>
> On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> > If a memcg is over high limit, memory reclaim is scheduled to run on
> > return-to-userland.  However it is assumed that the memcg is the current
> > process's memcg.  With remote memcg charging for kmem or swapping in a
> > page charged to remote memcg, current process can trigger reclaim on
> > remote memcg.  So, schduling reclaim on return-to-userland for remote
> > memcgs will ignore the high reclaim altogether. So, record the memcg
> > needing high reclaim and trigger high reclaim for that memcg on
> > return-to-userland.  However if the memcg is already recorded for high
> > reclaim and the recorded memcg is not the descendant of the the memcg
> > needing high reclaim, punt the high reclaim to the work queue.
>
> The idea behind remote charging is that the thread allocating the
> memory is not responsible for that memory, but a different cgroup
> is. Why would the same thread then have to work off any high excess
> this could produce in that unrelated group?
>
> Say you have a inotify/dnotify listener that is restricted in its
> memory use - now everybody sending notification events from outside
> that listener's group would get throttled on a cgroup over which it
> has no control. That sounds like a recipe for priority inversions.
>
> It seems to me we should only do reclaim-on-return when current is in
> the ill-behaved cgroup, and punt everything else - interrupts and
> remote charges - to the workqueue.

This is what v1 of this patch was doing but Michal suggested to do
what this version is doing. Michal's argument was that the current is
already charging and maybe reclaiming a remote memcg then why not do
the high excess reclaim as well.

Personally I don't have any strong opinion either way. What I actually
wanted was to punt this high reclaim to some process in that remote
memcg. However I didn't explore much on that direction thinking if
that complexity is worth it. Maybe I should at least explore it, so,
we can compare the solutions. What do you think?

Shakeel


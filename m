Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E10DC3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D067923400
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:43:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RqFGqfbZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D067923400
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D39F6B000E; Wed,  4 Sep 2019 01:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AA646B0010; Wed,  4 Sep 2019 01:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 598916B0266; Wed,  4 Sep 2019 01:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 368FD6B000E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:43:32 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D193C180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:43:31 +0000 (UTC)
X-FDA: 75896145822.25.pie97_761779eff7b5b
X-HE-Tag: pie97_761779eff7b5b
X-Filterd-Recvd-Size: 5499
Received: from mail-vs1-f65.google.com (mail-vs1-f65.google.com [209.85.217.65])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:43:31 +0000 (UTC)
Received: by mail-vs1-f65.google.com with SMTP id r1so10170296vsq.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 22:43:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JnRNNgV0YhAL6zDufOYnxx16nsh9d1vYCiomDUcaQzQ=;
        b=RqFGqfbZDZiAsCUpWiNxYO5pmn2x9w0/Zvk8sQAl2V9qUSyuDZlgKa6QeoZU+D2pNv
         bs3KZ1L49lefsiL2PWQHlG/LpXLNTQQ+pmDWVRTsWxS8zrQLdZlGW0paddD74QYIKRJN
         aURn8PGPDYOMHm3g31y+5fkF3Uj6ZXYd8v4IHMXpfh2kjCm+dMX5XaKvVryFFOBsSyWl
         Qt7DNTBYRDB1beJ4wYqZIIYEL44JTc2fuja8HsD/z6eEBnX3CtkHd058k0AyPf8AgyOi
         YCLaXcWiDZ3psUkjYa3D5Nm+krvlWmvf1O1f0YEda0pyMgxZOPKkhwLc+5lKomde3HFS
         08YA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JnRNNgV0YhAL6zDufOYnxx16nsh9d1vYCiomDUcaQzQ=;
        b=YTCHfEC98GhTj8K9n6PwAPhk0HKTgDPJlYyntsXj0uTjfVb0PfaJdIii8jOQxq9cVd
         zD/Bk0RAw3pftJKok1dgiJvmg9kAlGzYplu9ONZFdsV4glA8yjoZdDZmzxVLbLmdYrsq
         I4AcxA36wwZW5faG/bbAj69sWuoP32MTUS4Lg2ol33MAZ66emGDEb7faZ8307Cyu061/
         LbL7YP7ya8v0GfIadn8wFNg/jlvODjaLv4qydQi+wFedgiT9L6EL0t+0I/g0ont+UANP
         O6Ecq8TLzNTOj6CeyFf8uUCxmFUD5kghV3KXCf/O9CvLs0scWaC5JkZWf7aZEXM4zOG9
         Ci+A==
X-Gm-Message-State: APjAAAU6FR0UULW0T7kGHW60rr8mPWDld9uwuetc/1B7j2NR/x2N9ypr
	m3BTD6VVe2N1ZHwZDi02w33UhbsrOui0W2gE0oAv+Q==
X-Google-Smtp-Source: APXvYqy4TvaH76qmxeF5BmdOmJixuaYWpdfghYQi0jQADchL6HvuGRcDluiwa8aCHLdmq8mHdR0nieBZ+2g67xGlwWc=
X-Received: by 2002:a67:f606:: with SMTP id k6mr21358828vso.114.1567575810342;
 Tue, 03 Sep 2019 22:43:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
 <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com> <20190904051549.GB256568@google.com>
In-Reply-To: <20190904051549.GB256568@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 3 Sep 2019 22:42:53 -0700
Message-ID: <CAKOZuet_M7nu5PYQj1iZErXV8hSZnjv4kMokVyumixVXibveoQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Suren Baghdasaryan <surenb@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	Tim Murray <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, 
	Mayank Gupta <mayankgupta@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 10:15 PM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> On Tue, Sep 03, 2019 at 09:51:20PM -0700, Daniel Colascione wrote:
> > On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
> > >
> > > On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> > > <joel@joelfernandes.org> wrote:
> > > >
> > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > memory hogs. Several Android teams have been using this patch in various
> > > > kernel trees for half a year now. Many reported to me it is really
> > > > useful so I'm posting it upstream.
> >
> > It's also worth being able to turn off the per-task memory counter
> > caching, otherwise you'll have two levels of batching before the
> > counter gets updated, IIUC.
>
> I prefer to keep split RSS accounting turned on if it is available.

Why? AFAIK, nobody's produced numbers showing that split accounting
has a real benefit.

> I think
> discussing split RSS accounting is a bit out of scope of this patch as well.

It's in-scope, because with split RSS accounting, allocated memory can
stay accumulated in task structs for an indefinite time without being
flushed to the mm. As a result, if you take the stream of virtual
memory management system calls that  program makes on one hand, and VM
counter values on the other, the two don't add up. For various kinds
of robustness (trace self-checking, say) it's important that various
sources of data add up.

If we're adding a configuration knob that controls how often VM
counters get reflected in system trace points, we should also have a
knob to control delayed VM counter operations. The whole point is for
users to be able to specify how precisely they want VM counter changes
reported to analysis tools.

> Any improvements on that front can be a follow-up.
>
> Curious, has split RSS accounting shown you any issue with this patch?

Split accounting has been a source of confusion for a while now: it
causes that numbers-don't-add-up problem even when sampling from
procfs instead of reading memory tracepoint data.


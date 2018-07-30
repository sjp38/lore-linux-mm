Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A94AE6B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:51:24 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id a14-v6so7259920ybl.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:51:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6-v6sor2333615ywf.6.2018.07.30.10.51.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 10:51:23 -0700 (PDT)
Date: Mon, 30 Jul 2018 10:51:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180730175120.GJ1206094@devbig004.ftw2.facebook.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd>
 <20180730154035.GC4567@cmpxchg.org>
 <20180730173940.GB881@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730173940.GB881@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hello,

On Mon, Jul 30, 2018 at 07:39:40PM +0200, Pavel Machek wrote:
> > I'd rather have the internal config symbol match the naming scheme in
> > the code, where psi is a shorter, unique token as copmared to e.g.
> > pressure, press, prsr, etc.
> 
> I'd do "pressure", really. Yes, psi is shorter, but I'd say that
> length is not really important there.

This is an extreme bikeshedding without any relevance.  You can make
suggestions but please lay it to the rest.  There isn't any general
consensus against the current name and you're just trying to push your
favorite name without proper justifications after contributing nothing
to the project.  Please stop.

Thanks.

-- 
tejun

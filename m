Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 526C36B0273
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:07:59 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c67-v6so7608172ywc.21
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:07:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t84-v6sor2058615ywf.501.2018.07.30.11.07.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 11:07:58 -0700 (PDT)
Date: Mon, 30 Jul 2018 11:07:55 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180730180755.GM1206094@devbig004.ftw2.facebook.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd>
 <20180730154035.GC4567@cmpxchg.org>
 <20180730173940.GB881@amd>
 <20180730175120.GJ1206094@devbig004.ftw2.facebook.com>
 <20180730175936.GA2416@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730175936.GA2416@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jul 30, 2018 at 07:59:36PM +0200, Pavel Machek wrote:
> Its true I have no interest in psi. But I'm trying to use same kernel
> you are trying to "improve" and I was confused enough by seing
> "CONFIG_PSI". And yes, my association was "pounds per square inch" and
> "what is it doing here".

Read the help message.  If that's not enough, we sure can improve it.

> So I'm asking you to change the name.
> 
> USB is well known acronym, so it is okay to have CONFIG_USB. PSI is
> also well known -- but means something else.
> 
> And the code kind-of acknowledges that acronym is unknown, by having
> /proc/pressure.

Your momentary confusion isn't the only criterion.

Thanks.

-- 
tejun

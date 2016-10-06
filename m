Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDBF06B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 01:04:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n189so13161696qke.0
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 22:04:32 -0700 (PDT)
Received: from cmta17.telus.net (cmta17.telus.net. [209.171.16.90])
        by mx.google.com with ESMTP id y123si2085366qka.7.2016.10.05.22.04.31
        for <linux-mm@kvack.org>;
        Wed, 05 Oct 2016 22:04:31 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <bug-172981-27@https.bugzilla.kernel.org/> <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org> <20160928020347.GA21129@cmpxchg.org> <20160928080953.GA20312@esperanza> <20160929020050.GD29250@js1304-P5Q-DELUXE> <20160929134550.GB20312@esperanza> <20160930081940.GA3606@js1304-P5Q-DELUXE> q3x7bmIYYBMcWq3x9bnOYU
In-Reply-To: q3x7bmIYYBMcWq3x9bnOYU
Subject: RE: [Bug 172981] New: [bisected] SLAB: extreme load averages and over 2000 kworker threads
Date: Wed, 5 Oct 2016 22:04:27 -0700
Message-ID: <002601d21f8f$1fe2fe40$5fa8fac0$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vladimir Davydov' <vdavydov.dev@gmail.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 2016.09.30 12:59 Vladimir Davydov wrote:

> Yeah, you're right. We'd better do something about this
> synchronize_sched(). I think moving it out of the slab_mutex and calling
> it once for all caches in memcg_deactivate_kmem_caches() would resolve
> the issue. I'll post the patches tomorrow.

Would someone please be kind enough to send me the patch set?

I didn't get them, and would like to test them.
I have searched and searched and did manage to find:
"[PATCH 2/2] slub: move synchronize_sched out of slab_mutex on shrink"
And a thread about a patch 1 of 2:
"Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating per-memcg caches"
Where I see me as "reported by", but I guess "reported by" people don't get the e-mails.
I haven't found PATCH 0/2, nor do I know if what I did find is current.

... Doug


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32E926B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 02:35:18 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 189so26803846ity.1
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 23:35:18 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o144si16387745iod.235.2016.10.05.23.35.16
        for <linux-mm@kvack.org>;
        Wed, 05 Oct 2016 23:35:17 -0700 (PDT)
Date: Thu, 6 Oct 2016 15:35:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20161006063515.GB2525@js1304-P5Q-DELUXE>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <20160928020347.GA21129@cmpxchg.org>
 <20160928080953.GA20312@esperanza>
 <20160929020050.GD29250@js1304-P5Q-DELUXE>
 <20160929134550.GB20312@esperanza>
 <20160930081940.GA3606@js1304-P5Q-DELUXE>
 <002601d21f8f$1fe2fe40$5fa8fac0$@net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002601d21f8f$1fe2fe40$5fa8fac0$@net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: 'Vladimir Davydov' <vdavydov.dev@gmail.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Wed, Oct 05, 2016 at 10:04:27PM -0700, Doug Smythies wrote:
> On 2016.09.30 12:59 Vladimir Davydov wrote:
> 
> > Yeah, you're right. We'd better do something about this
> > synchronize_sched(). I think moving it out of the slab_mutex and calling
> > it once for all caches in memcg_deactivate_kmem_caches() would resolve
> > the issue. I'll post the patches tomorrow.
> 
> Would someone please be kind enough to send me the patch set?
> 
> I didn't get them, and would like to test them.
> I have searched and searched and did manage to find:
> "[PATCH 2/2] slub: move synchronize_sched out of slab_mutex on shrink"
> And a thread about a patch 1 of 2:
> "Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating per-memcg caches"
> Where I see me as "reported by", but I guess "reported by" people don't get the e-mails.
> I haven't found PATCH 0/2, nor do I know if what I did find is current.

I think that what you find is correct one. It has no cover-letter so
there is no [PATCH 0/2]. Anyway, to clarify, I add links to these
patches.

https://patchwork.kernel.org/patch/9361853
https://patchwork.kernel.org/patch/9359271

It would be very helpful if you test these patches.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

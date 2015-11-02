Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2B26B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:52:24 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so160036728pac.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:52:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fb8si36079503pab.221.2015.11.02.08.52.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Nov 2015 08:52:23 -0800 (PST)
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151029022447.GB27115@mtj.duckdns.org>
	<20151029030822.GD27115@mtj.duckdns.org>
	<alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
	<201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
Message-Id: <201511030152.JGF95845.SHVLOMtOJFFOFQ@I-love.SAKURA.ne.jp>
Date: Tue, 3 Nov 2015 01:52:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Christoph Lameter wrote:
> On Sat, 31 Oct 2015, Tetsuo Handa wrote:
> 
> > Then, you need to update below description (or drop it) because
> > patch 3/3 alone will not guarantee that the counters are up to date.
> 
> The vmstat system does not guarantee that the counters are up to date
> always. The whole point is the deferral of updates for performance
> reasons. They are updated *at some point* within stat_interval. That needs
> to happen and that is what this patchset is fixing.
> 
I'm still unclear. I think that the result of this patchset is

  The counters are never updated even after stat_interval
  if some workqueue item is doing a __GFP_WAIT memory allocation.

but the patch description sounds as if

  The counters will be updated even if some workqueue item is
  doing a __GFP_WAIT memory allocation.

which denies the actual result I tested with this patchset applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

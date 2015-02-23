Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2FED26B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 16:33:55 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so21938572igb.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:33:55 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id c33si29124133iod.28.2015.02.23.13.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 13:33:54 -0800 (PST)
Received: by mail-ig0-f179.google.com with SMTP id l13so21974954iga.0
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 13:33:54 -0800 (PST)
Date: Mon, 23 Feb 2015 13:33:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
In-Reply-To: <20150222002058.GB25079@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1502231332550.21127@chino.kir.corp.google.com>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp> <20150217125315.GA14287@phnom.home.cmpxchg.org> <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp> <20150220231511.GH12722@dastard> <20150221032000.GC7922@thunk.org> <20150221011907.2d26c979.akpm@linux-foundation.org> <20150222002058.GB25079@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

On Sat, 21 Feb 2015, Johannes Weiner wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> mm: page_alloc: revert inadvertent !__GFP_FS retry behavior change
> 
> Historically, !__GFP_FS allocations were not allowed to invoke the OOM
> killer once reclaim had failed, but nevertheless kept looping in the
> allocator.  9879de7373fc ("mm: page_alloc: embed OOM killing naturally
> into allocation slowpath"), which should have been a simple cleanup
> patch, accidentally changed the behavior to aborting the allocation at
> that point.  This creates problems with filesystem callers (?) that
> currently rely on the allocator waiting for other tasks to intervene.
> 
> Revert the behavior as it shouldn't have been changed as part of a
> cleanup patch.
> 
> Fixes: 9879de7373fc ("mm: page_alloc: embed OOM killing naturally into allocation slowpath")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Cc: stable@vger.kernel.org [3.19]
Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id C67766B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:26:35 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id x12so24664284wgg.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 02:26:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hu10si16716570wib.111.2015.02.23.02.26.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 02:26:34 -0800 (PST)
Date: Mon, 23 Feb 2015 11:26:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150223102633.GC24272@dhcp22.suse.cz>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
 <20150220231511.GH12722@dastard>
 <20150221032000.GC7922@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150221032000.GC7922@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

On Fri 20-02-15 22:20:00, Theodore Ts'o wrote:
[...]
> So based on akpm's sage advise and wisdom, I added back GFP_NOFAIL to
> ext4/jbd2.

I am currently going through opencoded GFP_NOFAIL allocations and have
this in my local branch currently. I assume you did the same so I will
drop mine if you have pushed yours already.
---

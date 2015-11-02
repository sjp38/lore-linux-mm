Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id ACB4D82F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:12:58 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so56920105igb.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:12:58 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id l12si12585109igf.97.2015.11.02.08.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 08:12:58 -0800 (PST)
Date: Mon, 2 Nov 2015 10:12:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
References: <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org> <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp> <20151029022447.GB27115@mtj.duckdns.org> <20151029030822.GD27115@mtj.duckdns.org> <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
 <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Sat, 31 Oct 2015, Tetsuo Handa wrote:

> Then, you need to update below description (or drop it) because
> patch 3/3 alone will not guarantee that the counters are up to date.

The vmstat system does not guarantee that the counters are up to date
always. The whole point is the deferral of updates for performance
reasons. They are updated *at some point* within stat_interval. That needs
to happen and that is what this patchset is fixing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

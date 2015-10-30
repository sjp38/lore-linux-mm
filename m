Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id AEBB982F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 21:01:15 -0400 (EDT)
Received: by igpw7 with SMTP id w7so1146402igp.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 18:01:15 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id j10si259292igj.4.2015.10.29.18.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 29 Oct 2015 18:01:14 -0700 (PDT)
Date: Thu, 29 Oct 2015 20:01:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <20151029030822.GD27115@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
References: <20151028024114.370693277@linux.com> <20151028024131.719968999@linux.com> <20151028024350.GA10448@mtj.duckdns.org> <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org> <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
 <20151029022447.GB27115@mtj.duckdns.org> <20151029030822.GD27115@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Thu, 29 Oct 2015, Tejun Heo wrote:

> Wait, this series doesn't include Tetsuo's change.  Of course it won't
> fix the deadlock problem.  What's necessary is Tetsuo's patch +
> WQ_MEM_RECLAIM.

This series is only dealing with vmstat changes. Do I get an ack here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6E36382F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 18:32:18 -0400 (EDT)
Received: by iodd200 with SMTP id d200so26977287iod.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 15:32:18 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id y6si243944iga.95.2015.10.28.15.32.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Oct 2015 15:32:17 -0700 (PDT)
Date: Wed, 28 Oct 2015 17:32:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1510281730410.15758@east.gentwo.org>
References: <20151028024114.370693277@linux.com> <20151028024131.719968999@linux.com> <20151028024350.GA10448@mtj.duckdns.org> <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org> <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Wed, 28 Oct 2015, Tetsuo Handa wrote:

> Christoph Lameter wrote:
> > On Wed, 28 Oct 2015, Tejun Heo wrote:
> >
> > > The only thing necessary here is WQ_MEM_RECLAIM.  I don't see how
> > > WQ_SYSFS and WQ_FREEZABLE make sense here.
> >
> I can still trigger silent livelock with this patchset applied.

Ok so why the vmstat updater still deferred, Tejun?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

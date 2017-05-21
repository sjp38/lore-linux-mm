Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0B3280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 16:01:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 139so21324860wmf.5
        for <linux-mm@kvack.org>; Sun, 21 May 2017 13:01:12 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l193si7230934wmg.30.2017.05.21.13.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 21 May 2017 13:01:10 -0700 (PDT)
Date: Sun, 21 May 2017 22:01:07 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] slub/memcg: Cure the brainless abuse of sysfs
 attributes
In-Reply-To: <20170520131645.GA5058@infradead.org>
Message-ID: <alpine.DEB.2.20.1705212200070.3023@nanos>
References: <alpine.DEB.2.20.1705201244540.2255@nanos> <20170520131645.GA5058@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

On Sat, 20 May 2017, Christoph Hellwig wrote:

> On Sat, May 20, 2017 at 12:52:03PM +0200, Thomas Gleixner wrote:
> > This should be rewritten proper by adding a propagate() callback to those
> > slub_attributes which must be propagated and avoid that insane conversion
> > to and from ASCII
> 
> Exactly..
> 
> >, but that's too large for a hot fix.
> 
> What made this such a hot fix?  Looks like this crap has been in
> for quite a while.
 
Well, having something in tree which uses stale or uninitialized buffers
does justify a hot fix which can be easily backported to stable.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DDD406B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:09:38 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id lf10so4433059pab.13
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:09:38 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id ki1si8850371pbc.265.2014.03.07.09.09.37
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:09:37 -0800 (PST)
Date: Fri, 7 Mar 2014 11:09:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -next] slub: Replace __this_cpu_inc usage w/ SLUB_STATS
In-Reply-To: <20140306182941.GH18529@joshc.qualcomm.com>
Message-ID: <alpine.DEB.2.10.1403071108310.21846@nuc>
References: <20140306194821.3715d0b6212cc10415374a68@canb.auug.org.au> <20140306155316.GG18529@joshc.qualcomm.com> <20140306182941.GH18529@joshc.qualcomm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Cartwright <joshc@codeaurora.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 6 Mar 2014, Josh Cartwright wrote:

> Although, I'm wondering how exact these statistics need to be.  Is
> making them preemption safe even a concern?

Not sure about that. You solution makes it preempt safe. If is can be
tolerated that its racy then raw_cpu_inc() could be used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

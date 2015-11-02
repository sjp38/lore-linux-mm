Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCB56B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 13:10:08 -0500 (EST)
Received: by obctp1 with SMTP id tp1so100627555obc.2
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 10:10:07 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id no3si12459667oeb.29.2015.11.02.10.10.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 10:10:07 -0800 (PST)
Date: Mon, 2 Nov 2015 12:10:04 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <201511030152.JGF95845.SHVLOMtOJFFOFQ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1511021209150.28799@east.gentwo.org>
References: <20151029022447.GB27115@mtj.duckdns.org> <20151029030822.GD27115@mtj.duckdns.org> <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org> <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
 <201511030152.JGF95845.SHVLOMtOJFFOFQ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Tue, 3 Nov 2015, Tetsuo Handa wrote:

> I'm still unclear. I think that the result of this patchset is
>
>   The counters are never updated even after stat_interval
>   if some workqueue item is doing a __GFP_WAIT memory allocation.
>
> but the patch description sounds as if
>
>   The counters will be updated even if some workqueue item is
>   doing a __GFP_WAIT memory allocation.
>
> which denies the actual result I tested with this patchset applied.

Well true that is dependend on the correct workqueue operation. I though
that was fixed by Tejun?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

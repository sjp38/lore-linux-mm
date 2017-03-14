Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F133E6B038C
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:51:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l37so49753733wrc.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 06:51:34 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id q14si5188635wrc.151.2017.03.14.06.51.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 06:51:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 5274021010B
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:51:33 +0000 (UTC)
Date: Tue, 14 Mar 2017 13:51:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
Message-ID: <20170314135132.6nfsr7f5xevpss6n@techsingularity.net>
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
 <20170313111947.rdydbpblymc6a73x@techsingularity.net>
 <58C6A5C5.9070301@huawei.com>
 <20170313142636.ghschfm2sff7j7oh@techsingularity.net>
 <58C7DCCA.6080603@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58C7DCCA.6080603@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org

On Tue, Mar 14, 2017 at 08:06:34PM +0800, zhong jiang wrote:
> >> you mean the removing cpu maybe  handle the IRQ, it will result in the incorrect pcpu->count ?
> >>
> > Yes, if it hasn't had interrupts disabled yet at the time of the drain.
> > I didn't check, it probably is called from a context that disables
> > interrupts but the fact you're not sure makes me automatically wary of
> > the patch particularly given how little difference it makes for the common
> > case where direct reclaim failed triggering a drain.
> >
> >> but I don't sure that dying cpu remain handle the IRQ.
> >>
> > You'd need to be certain to justify the patch.
> >
>  Hi,  Mel
>    
>     by code review,  I see the cpu hotplug will only register the notfier to callback the function without
>   interrupt come.  is it right ??
> 

That sentence is impossible to parse meaningfully. The patch was
posted without verifying it made any performance difference (it almost
certainly won't) and without checking all the callers are actually safe
(which you're still not sure of).

Consider the patch NAK'd on both grounds (marginal, if any improvement
with no checking that the patch is safe).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

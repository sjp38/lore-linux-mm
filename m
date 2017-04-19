Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91C096B03AC
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:22:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y33so5904571qta.7
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 06:22:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t63si2280418qka.317.2017.04.19.06.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 06:22:19 -0700 (PDT)
Date: Wed, 19 Apr 2017 15:22:16 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170419132212.GA3514@redhat.com>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
 <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
 <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
 <20170419111342.GF29789@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419111342.GF29789@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Wed, Apr 19, 2017 at 01:13:43PM +0200, Michal Hocko wrote:
> On Tue 18-04-17 14:47:32, David Rientjes wrote:
> [...]
> > I think the debug_guardpage_minorder() check makes sense for failed 
> > allocations because we are essentially removing memory from the system for 
> > debug, failed allocations as a result of low on memory or fragmentation 
> > aren't concerning if we are removing memory from the system.
> 
> I really fail to see how this is any different from booting with
> mem=$SIZE to reduce the amount of available memory.

mem= shrink upper memory limit, debug_guardpage_minorder= fragments
available physical memory (deliberately to catch unintended access).

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

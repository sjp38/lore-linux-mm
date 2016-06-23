Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5261A6B0005
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 17:45:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so199336894pfa.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 14:45:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x5si2169569pac.165.2016.06.23.14.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 14:45:39 -0700 (PDT)
Date: Thu, 23 Jun 2016 14:45:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
Message-Id: <20160623144538.0aa972c197de47ac31a4de3e@linux-foundation.org>
In-Reply-To: <20160623102648.GP1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
	<20160623102648.GP1868@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Jun 2016 11:26:48 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Tue, Jun 21, 2016 at 03:15:39PM +0100, Mel Gorman wrote:
> > The bulk of the updates are in response to review from Vlastimil Babka
> > and received a lot more testing than v6.
> > 
> 
> Hi Andrew,
> 
> Please drop these patches again from mmotm.

Done.  Silently, to avoid wearing out various inboxes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

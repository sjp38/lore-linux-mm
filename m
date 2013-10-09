Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A452A6B003A
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:09:43 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1360813pad.14
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:09:43 -0700 (PDT)
Received: by mail-ee0-f49.google.com with SMTP id d41so559833eek.8
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:09:36 -0700 (PDT)
Date: Wed, 9 Oct 2013 19:09:34 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009170934.GA12601@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009162801.GA10452@gmail.com>
 <20131009162942.GA12178@gmail.com>
 <20131009165738.GA12572@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009165738.GA12572@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


I started bisecting the crash, and the good news is that it's bisectable 
and it's not the NUMA bits that are causing the crash.

(the bad news is that I now face a boring, possibly very long bisection, 
but hey ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

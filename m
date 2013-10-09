Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 594A86B0055
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 12:57:44 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1229537pdj.15
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:57:44 -0700 (PDT)
Received: by mail-ea0-f179.google.com with SMTP id b10so559758eae.38
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:57:40 -0700 (PDT)
Date: Wed, 9 Oct 2013 18:57:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009165738.GA12572@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009162801.GA10452@gmail.com>
 <20131009162942.GA12178@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009162942.GA12178@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


an interesting aspect is that this is a 32-bit UP kernel.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

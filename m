Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id CE5DF6B007B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:56:13 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id m15so1944175wgh.26
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:56:12 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id cn2si13632415wib.60.2014.10.21.10.56.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 10:56:11 -0700 (PDT)
Date: Tue, 21 Oct 2014 19:56:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141021175603.GI3219@twins.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
 <20141021170948.GA25964@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021170948.GA25964@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 21, 2014 at 08:09:48PM +0300, Kirill A. Shutemov wrote:
> It would be interesting to see if the patchset affects non-condended case.
> Like a one-threaded workload.

It does, and not in a good way, I'll have to look at that... :/

 Performance counter stats for './multi-fault 1' (5 runs):

        73,860,251      page-faults                                                   ( +-  0.28% )
            40,914      cache-misses                                                  ( +- 41.26% )

      60.001484913 seconds time elapsed                                          ( +-  0.00% )


 Performance counter stats for './multi-fault 1' (5 runs):

        70,700,838      page-faults                                                   ( +-  0.03% )
            31,466      cache-misses                                                  ( +-  8.62% )

      60.001753906 seconds time elapsed                                          ( +-  0.00% )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

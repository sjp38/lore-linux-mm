Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0D8B6B025F
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 21:02:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l24so15599143pgu.22
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 18:02:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t6si822914plo.827.2017.10.24.18.02.04
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 18:02:04 -0700 (PDT)
Date: Wed, 25 Oct 2017 10:01:55 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 2/8] lockdep: Introduce CROSSRELEASE_STACK_TRACE and
 make it not unwind as default
Message-ID: <20171025010155.GO3310@X58A-UD3R>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
 <1508837889-16932-3-git-send-email-byungchul.park@lge.com>
 <20171024100516.f2a2uzknqfum77w2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024100516.f2a2uzknqfum77w2@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, axboe@kernel.dk, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

On Tue, Oct 24, 2017 at 12:05:16PM +0200, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > Johan Hovold reported a performance regression by crossrelease like:
> 
> Pplease add Reported-by and Analyzed-by tags - you didn't even Cc: Johan!

Excuse me but, I am sure, whom is the issue analyzed by? Me?

> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F26206B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 02:31:27 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g37-v6so285098wrd.12
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 23:31:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13-v6sor12063883wrv.12.2018.10.08.23.31.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 23:31:26 -0700 (PDT)
Date: Tue, 9 Oct 2018 08:31:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm,numa: Remove remaining traces of rate-limiting.
Message-ID: <20181009063123.GA66632@gmail.com>
References: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20181008170149.GB5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181008170149.GB5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>


* Mel Gorman <mgorman@techsingularity.net> wrote:

> On Sat, Oct 06, 2018 at 04:53:19PM +0530, Srikar Dronamraju wrote:
> > With Commit efaffc5e40ae ("mm, sched/numa: Remove rate-limiting of automatic
> > NUMA balancing migration"), we no more require migrate lock and its
> > initialization. Its redundant. Hence remove it.
> > 
> > Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 
> Hi Ingo, 
> 
> Can this be sent with the rest of the patches that got merged for 4.19-rc7
> so they are more or less together? It's functionally harmless to delay
> until the 4.20 merge window but it's a bit untidy. The mistake was mine
> switching between a backport and mainline versions of the original patch.
> 
> Thanks

Ok, agreed and done - I queued it up in sched/urgent.

Thanks,

	Ingo

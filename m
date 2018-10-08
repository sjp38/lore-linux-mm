Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 350EF6B000A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 13:01:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m25-v6so4982587edp.12
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 10:01:53 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id y16si2390450edw.172.2018.10.08.10.01.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Oct 2018 10:01:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 2E31B98AC0
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 17:01:51 +0000 (UTC)
Date: Mon, 8 Oct 2018 18:01:49 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm,numa: Remove remaining traces of rate-limiting.
Message-ID: <20181008170149.GB5819@techsingularity.net>
References: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>

On Sat, Oct 06, 2018 at 04:53:19PM +0530, Srikar Dronamraju wrote:
> With Commit efaffc5e40ae ("mm, sched/numa: Remove rate-limiting of automatic
> NUMA balancing migration"), we no more require migrate lock and its
> initialization. Its redundant. Hence remove it.
> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Hi Ingo, 

Can this be sent with the rest of the patches that got merged for 4.19-rc7
so they are more or less together? It's functionally harmless to delay
until the 4.20 merge window but it's a bit untidy. The mistake was mine
switching between a backport and mainline versions of the original patch.

Thanks

-- 
Mel Gorman
SUSE Labs

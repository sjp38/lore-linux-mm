Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D85776B000A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2018 09:29:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x44-v6so2918788edd.17
        for <linux-mm@kvack.org>; Sat, 06 Oct 2018 06:29:02 -0700 (PDT)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id z4-v6si10125605edk.73.2018.10.06.06.29.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Oct 2018 06:29:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id E14C9B8723
	for <linux-mm@kvack.org>; Sat,  6 Oct 2018 14:29:00 +0100 (IST)
Date: Sat, 6 Oct 2018 14:23:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm,numa: Remove remaining traces of rate-limiting.
Message-ID: <20181006132319.GA5819@techsingularity.net>
References: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1538824999-31230-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>

On Sat, Oct 06, 2018 at 04:53:19PM +0530, Srikar Dronamraju wrote:
> With Commit efaffc5e40ae ("mm, sched/numa: Remove rate-limiting of automatic
> NUMA balancing migration"), we no more require migrate lock and its
> initialization. Its redundant. Hence remove it.
> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

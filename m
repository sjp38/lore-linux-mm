Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72F436B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:10:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a186so2570979wmh.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:10:24 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id l64si2130634edl.302.2017.08.10.04.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 04:10:22 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id o33so349557wrb.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:10:22 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:10:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170810111019.n376bsm6h4de2jvi@gmail.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> Change from v7
> 	- rebase on latest tip/sched/core (Jul 26 2017)
> 	- apply peterz's suggestions
> 	- simplify code of crossrelease_{hist/soft/hard}_{start/end}
> 	- exclude a patch avoiding redundant links
> 	- exclude a patch already applied onto the base

Ok, it's looking pretty good here now, there's one thing I'd like you to change, 
please remove all the new Kconfig dependencies:

 CONFIG_LOCKDEP_CROSSRELEASE=y
 CONFIG_LOCKDEP_COMPLETE=y

and make it all part of PROVE_LOCKING, like most of the other lock debugging bits.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

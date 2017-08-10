Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15FC06B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:36:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l2so82875247pgu.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:36:17 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a20si3379936pfc.420.2017.08.09.18.36.15
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 18:36:16 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:35:02 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 11/14] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20170810013501.GY20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-12-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502089981-21272-12-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 07, 2017 at 04:12:58PM +0900, Byungchul Park wrote:
> Although lock_page() and its family can cause deadlock, the lock
> correctness validator could not be applied to them until now, becasue
> things like unlock_page() might be called in a different context from
> the acquisition context, which violates lockdep's assumption.
> 
> Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
> detector to page locks. Applied it.

Is there any reason excluding applying it into PG_locked?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

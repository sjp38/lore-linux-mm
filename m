Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC2426B038B
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 05:45:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n89so43743093pfa.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 02:45:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o3si4288821pld.201.2017.03.01.02.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 02:45:47 -0800 (PST)
Date: Wed, 1 Mar 2017 11:45:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301104548.GE6515@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228131012.GI5680@worktop>
 <20170228132444.GG3817@X58A-UD3R>
 <20170228182902.GN5680@worktop>
 <20170301044033.GC11663@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301044033.GC11663@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 01:40:33PM +0900, Byungchul Park wrote:

> Right. I decided to force MAX_XHLOCKS_NR to be power of 2 and everything
> became easy. Thank you very much.

Something like:

	BUILD_BUG_ON(MAX_XHLOCKS_NR & (MAX_XHLOCK_NR - 1));

Should enforce I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 553216B026E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:13:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so17892221pgc.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:13:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l59si359224plb.85.2017.01.18.06.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 06:13:01 -0800 (PST)
Date: Wed, 18 Jan 2017 15:12:55 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170118141255.GE6515@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170118064230.GF15084@tardis.cn.ibm.com>
 <20170118105346.GL3326@X58A-UD3R>
 <20170118110317.GC6515@twins.programming.kicks-ass.net>
 <20170118115428.GM3326@X58A-UD3R>
 <20170118120757.GD6515@twins.programming.kicks-ass.net>
 <008101d27184$7d3cbd00$77b63700$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <008101d27184$7d3cbd00$77b63700$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "byungchul.park" <byungchul.park@lge.com>
Cc: 'Boqun Feng' <boqun.feng@gmail.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 09:14:59PM +0900, byungchul.park wrote:

> +Example 3:
> +
> +   CONTEXT X		   CONTEXT Y
> +   ---------		   ---------
> +			   mutex_lock A
> +   mutex_lock A
> +   mutex_unlock A
> +			   wait_for_complete B /* DEADLOCK */

Each line (across both columns) is a distinct point in time after the
line before.

Therefore, this states that "mutex_unlock A" happens before
"wait_for_completion B", which is clearly impossible.

You don't have to remove everything after mutex_lock A, but the unlock
must not happen before context Y does the unlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

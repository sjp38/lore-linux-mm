Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5196F6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 11:06:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so43417829wms.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 08:06:55 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id a186si11285805wma.80.2016.11.07.08.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 08:06:54 -0800 (PST)
Date: Mon, 7 Nov 2016 08:06:53 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH/RFC] z3fold: use per-page read/write lock
Message-ID: <20161107160652.GJ26852@two.firstfloor.org>
References: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com>
 <87lgwxo5u9.fsf@tassilo.jf.intel.com>
 <CAMJBoFNWV92c5B3HLJ=6wgNNUJFpTUgu3qf1mWgYxTEhfaA_LA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFNWV92c5B3HLJ=6wgNNUJFpTUgu3qf1mWgYxTEhfaA_LA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

> I understand the reinvention part but you're not quite accurate here
> with the numbers.
> 
> E. g. on x86_64:
> (gdb) p sizeof(rwlock_t)
> $1 = 8

I was talking about spinlocks which are 4 bytes.  Just use a spinlock then. 
rwlocks are usually a bad idea anyways because they often scale far worse than
spinlocks due to the bad cache line bouncing behavior, and it doesn't
make much difference unless your critical section is very long.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id D133E6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:12:43 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so3714187qen.29
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:12:43 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k3si11028202qao.186.2013.12.16.02.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Dec 2013 02:12:43 -0800 (PST)
Date: Mon, 16 Dec 2013 11:12:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: ptl is not bloated if it fits in pointer
Message-ID: <20131216101233.GV21999@twins.programming.kicks-ass.net>
References: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 16, 2013 at 01:04:13AM -0800, Hugh Dickins wrote:
> It's silly to force the 64-bit CONFIG_GENERIC_LOCKBREAK architectures

So yes that's unfortunate, but why are people using that
GENERIC_LOCKBREAK stuff to begin with? Its atrocious, a much better path
would be to remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

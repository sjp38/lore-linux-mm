Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4A45A6B0035
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 11:26:41 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x13so12336605qcv.1
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 08:26:41 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id x8si20562429qch.25.2013.12.31.08.26.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Dec 2013 08:26:40 -0800 (PST)
Date: Tue, 31 Dec 2013 17:26:36 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 1/2] mm: additional page lock debugging
Message-ID: <20131231162636.GD16438@laptop.programming.kicks-ass.net>
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
 <20131230114317.GA8117@node.dhcp.inet.fi>
 <52C1A06B.4070605@oracle.com>
 <20131230224808.GA11674@node.dhcp.inet.fi>
 <52C2385A.8020608@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C2385A.8020608@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Dec 30, 2013 at 10:22:02PM -0500, Sasha Levin wrote:

> I really want to use lockdep here, but I'm not really sure how to handle locks which live
> for a rather long while instead of being locked and unlocked in the same function like
> most of the rest of the kernel. (Cc Ingo, PeterZ).

Uh what? Lockdep doesn't care about which function locks and unlocks a
particular lock. Nor does it care how long its held for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B41D8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 14:59:30 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p1PJxQSX026138
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 11:59:28 -0800
Received: from vws7 (vws7.prod.google.com [10.241.21.135])
	by kpbe20.cbf.corp.google.com with ESMTP id p1PJukIs018052
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 11:59:25 -0800
Received: by vws7 with SMTP id 7so1948084vws.8
        for <linux-mm@kvack.org>; Fri, 25 Feb 2011 11:59:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1298663105.2428.2693.camel@twins>
References: <20110217162327.434629380@chello.nl>
	<20110217163235.106239192@chello.nl>
	<1298565253.2428.288.camel@twins>
	<1298657083.2428.2483.camel@twins>
	<1298663105.2428.2693.camel@twins>
Date: Fri, 25 Feb 2011 11:59:23 -0800
Message-ID: <AANLkTinLv=oy5_nPdziV6gpG-BLedsrNF0ew4Wz3x690@mail.gmail.com>
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Russell King <rmk@arm.linux.org.uk>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>

On Fri, Feb 25, 2011 at 11:45 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> Grmbl.. so doing that would require flush_tlb_range() to take an mm, not
> a vma, but tile and arm both use the vma->flags & VM_EXEC test to avoid
> flushing their i-tlbs.
>
> I'm tempted to make them flush i-tlbs unconditionally as its still
> better than hitting an mm wide tlb flush due to the page table free.
>
> Ideas?

What's wrong with using vma->vm_mm?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

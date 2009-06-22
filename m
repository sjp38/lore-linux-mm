Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA816B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 05:26:30 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n5M9QBX9557430
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 09:26:11 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5M9QBEg2937032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 11:26:11 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5M9QApQ018180
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 11:26:11 +0200
Date: Mon, 22 Jun 2009 11:26:09 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: handle_mm_fault() calling convention cleanup..
Message-ID: <20090622112609.118f53ae@skybase>
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Jun 2009 13:42:35 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Just a heads up that I committed the patches that I sent out two months 
> ago to make the fault handling routines use the finer-grained fault flags 
> (FAULT_FLAG_xyzzy) rather than passing in a boolean for "write".

Todays git tree still works on s390.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

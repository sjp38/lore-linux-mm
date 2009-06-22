Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 470206B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 04:10:37 -0400 (EDT)
Date: Mon, 22 Jun 2009 10:10:45 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: handle_mm_fault() calling convention cleanup..
Message-ID: <20090622081045.GB11041@elte.hu>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Just a heads up that I committed the patches that I sent out two 
> months ago to make the fault handling routines use the 
> finer-grained fault flags (FAULT_FLAG_xyzzy) rather than passing 
> in a boolean for "write".

All is fine on x86.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

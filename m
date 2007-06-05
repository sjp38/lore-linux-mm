Date: Tue, 5 Jun 2007 12:46:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] mm: move_page_tables{,_up}
In-Reply-To: <20070605151203.738393000@chello.nl>
Message-ID: <Pine.LNX.4.64.0706051244010.3432@schroedinger.engr.sgi.com>
References: <20070605150523.786600000@chello.nl> <20070605151203.738393000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jun 2007, Peter Zijlstra wrote:

> Provide functions for moving page tables upwards.

Could you make this more general so that it allows arbitrary page table 
pages moving? That would be useful for Mel's memory defragmentation since 
it increases the types of pages that can be moved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

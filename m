Date: Wed, 30 Jan 2008 14:40:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-Id: <20080130144049.73596898.akpm@linux-foundation.org>
In-Reply-To: <1201714139.28547.237.camel@lappy>
References: <1201714139.28547.237.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008 18:28:59 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Implement MADV_WILLNEED for anonymous pages by walking the page tables and
> starting asynchonous swap cache reads for all encountered swap pages.

Why cannot this use (a perhaps suitably-modified) make_pages_present()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

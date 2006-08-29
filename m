Date: Tue, 29 Aug 2006 16:20:20 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [PATCH 3/6] uml: arch/um remove_mapping() clash
Message-ID: <20060829202020.GB12080@ccure.user-mode-linux.org>
References: <20060825153709.24254.28118.sendpatchset@twins> <20060825153740.24254.20935.sendpatchset@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060825153740.24254.20935.sendpatchset@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@osdl.org>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 25, 2006 at 05:37:40PM +0200, Peter Zijlstra wrote:
> Now that 'include/linux/mm.h' includes 'include/linux/swap.h', the global
> remove_mapping() definition clashes with the arch/um one.
> 
> Rename the arch/um one.

If you tested the UML build -

Acked-by: Jeff Dike <jdike@addtoit.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

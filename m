Received: by rv-out-0910.google.com with SMTP id l15so736182rvb
        for <linux-mm@kvack.org>; Fri, 12 Oct 2007 14:45:48 -0700 (PDT)
Message-ID: <84144f020710121445p23fcc21am18482e01856cdc35@mail.gmail.com>
Date: Sat, 13 Oct 2007 00:45:48 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <Pine.LNX.4.64.0710120129080.16588@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200710071920.l97JKJX5018871@agora.fsl.cs.sunysb.edu>
	 <20071011144740.136b31a8.akpm@linux-foundation.org>
	 <cfa94dc20710111512j9b6c038qf89c516ecd605411@mail.gmail.com>
	 <Pine.LNX.4.64.0710120129080.16588@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, Erez Zadok <ezk@cs.sunysb.edu>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On 10/12/07, Hugh Dickins <hugh@veritas.com> wrote:
> But I keep suspecting that the answer might be the patch below (which
> rather follows what drivers/block/rd.c is doing).  I'm especially
> worried that, rather than just AOP_WRITEPAGE_ACTIVATE being returned
> to userspace, bad enough in itself, you might be liable to hit that
> BUG_ON(page_mapped(page)).  shmem_writepage does not expect to be
> called by anyone outside mm/vmscan.c, but unionfs can now get to it?

Doesn't msync(2) get to it via mm/page-writeback.c:write_cache_pages()
without unionfs even?

                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

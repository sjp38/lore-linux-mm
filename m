Date: Sat, 23 Oct 2004 23:26:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Migration cache
In-Reply-To: <20041023192857.GA12334@logos.cnet>
Message-ID: <Pine.LNX.4.44.0410232324290.2977-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Oct 2004, Marcelo Tosatti wrote:
> 
> Oh and with that we no longer need PG_migration bit, but, page->private 
> does not contain swp_type information (MIGRATION_TYPE bit) in it. Its simply 
> an offset counting from 0 increasing sequentially. 
> 
> ANDing migration type bit into the offset should work.

I haven't looked, but wouldn't it be a lot easier to use the normal
swap allocation code rather than going such a different idr way here?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Sun, 24 Oct 2004 10:21:33 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Migration cache
Message-ID: <20041024122133.GA17762@logos.cnet>
References: <20041023192857.GA12334@logos.cnet> <Pine.LNX.4.44.0410232324290.2977-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410232324290.2977-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 23, 2004 at 11:26:39PM +0100, Hugh Dickins wrote:
> On Sat, 23 Oct 2004, Marcelo Tosatti wrote:
> > 
> > Oh and with that we no longer need PG_migration bit, but, page->private 
> > does not contain swp_type information (MIGRATION_TYPE bit) in it. Its simply 
> > an offset counting from 0 increasing sequentially. 
> > 
> > ANDing migration type bit into the offset should work.
> 
> I haven't looked, but wouldn't it be a lot easier to use the normal
> swap allocation code rather than going such a different idr way here?

Hi Hugh,

Well, the idr code is quite simple, but yes, 
we could probably reuse the swap allocation code.

Would have to create a swap_info_struct, without 
the swap extent stuff and no bdev pointer. May
require some modifications but should work.

BTW, while I was reading the code, I wondered:

struct swap_info_struct swap_info[MAX_SWAPFILES];

This array should be created dynamically. Worth 
the trouble?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 30 Mar 2007 05:01:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/4] holepunch: fix shmem_truncate_range punching too
 far
In-Reply-To: <87slbn64zi.wl%peterc@chubb.wattle.id.au>
Message-ID: <Pine.LNX.4.64.0703300458060.32407@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
 <E1HWsJq-0000vz-00@dorka.pomaz.szeredi.hu> <87slbn64zi.wl%peterc@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mszeredi@suse.cz, pbadari@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Mar 2007, Peter Chubb wrote:
> >> + if (end + 1 >= inode->i_size) { /* we may free  a little more */
> 
> Miklos> Why end + 1?  If the hole end is at 4096 and the file size is
> Miklos> 4097 we surely don't want to truncate that second page also?
> 
> Why not simplify it to end > inode->i_size?  I think it then makes
> more sense.

One reason would be, that 2 + 1 >= 3, but I don't think 2 > 3 ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

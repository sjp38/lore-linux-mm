Date: Sun, 24 Oct 2004 16:37:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Migration cache
In-Reply-To: <20041024122133.GA17762@logos.cnet>
Message-ID: <Pine.LNX.4.44.0410241633530.12020-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Oct 2004, Marcelo Tosatti wrote:
> 
> BTW, while I was reading the code, I wondered:
> 
> struct swap_info_struct swap_info[MAX_SWAPFILES];
> 
> This array should be created dynamically. Worth 
> the trouble?

It is rather primitive, but I don't think it's worth the trouble to
change it on its own - certainly not worth changing it to allocate
the full array at runtime, and if you changed it to allocate slot by
slot then quite a few places (within swapfile.c) would need changing.
I can imagine someone doing a big cleanup of swapfile.c in which that
static array vanished, but I don't think it's worth doing on its own.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

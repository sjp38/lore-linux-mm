Date: Thu, 2 Oct 2008 16:11:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm owner: fix race between swapoff and exit
Message-Id: <20081002161159.735cbb85.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0809261344190.27666@blonde.site>
References: <Pine.LNX.4.64.0809250117220.26422@blonde.site>
	<48DCC068.30706@gmail.com>
	<Pine.LNX.4.64.0809261344190.27666@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: jirislaby@gmail.com, torvalds@linux-foundation.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyuki@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 14:36:55 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> > BTW there is also mm->owner = NULL; movement in the patch to the line before
> > the callbacks are invoked which I don't understand much (why to inform
> > anybody about NULL->NULL change?), but the first hunk seems reasonable to me.
> 
> You draw attention to the second hunk of
> memrlimit-setup-the-memrlimit-controller-mm_owner-fix
> (shown below).  It's just nonsense, isn't it, reverting the fix you
> already made?  Perhaps it's not the patch Balbir and Zefan actually
> submitted, but a mismerge of that with the fluctuating state of
> all these accumulated fixes in the mm tree, and nobody properly
> tested the issue in question on the resulting tree.
> 
> Or is the whole patch pointless, the first hunk just an attempt
> to handle the nonsense of the second hunk?
> 
> I wish there were a lot more care and a lot less churn in this area.

I really don't see those patches going anywhere and they are, to some
extent, getting in the way of real work.

I'm thinking lets-drop-them-all thoughts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

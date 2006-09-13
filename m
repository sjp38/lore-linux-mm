Subject: Re: [PATCH 2.6.18-rc6.mm2] revert migrate_move_mapping to use
	direct radix tree slot update
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0609131344450.19101@schroedinger.engr.sgi.com>
References: <1158174574.5328.37.camel@localhost>
	 <Pine.LNX.4.64.0609131344450.19101@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 17:40:22 -0400
Message-Id: <1158183622.5328.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-13 at 13:48 -0700, Christoph Lameter wrote:
> On Wed, 13 Sep 2006, Lee Schermerhorn wrote:
> 
>  > Now that the problem with the rcu radix tree replace slot function has
> > been fixed, we can, if Christoph agrees:
> 
> Instead of a new patch we could simply drop the patch
> 
> page-migration-replace-radix_tree_lookup_slot-with-radix_tree_lockup.patch
> 
> from Andrew's tree.

If you want to do it that way, I'll need to supply another patch to
clean up the compiler warnings [I think they were just warnings]
resulting from the change [at your suggestion ;-)] in the interface to
the radix tree functions.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

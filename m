Date: Wed, 13 Sep 2006 13:48:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.18-rc6.mm2] revert migrate_move_mapping to use direct
 radix tree slot update
In-Reply-To: <1158174574.5328.37.camel@localhost>
Message-ID: <Pine.LNX.4.64.0609131344450.19101@schroedinger.engr.sgi.com>
References: <1158174574.5328.37.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Lee Schermerhorn wrote:

 > Now that the problem with the rcu radix tree replace slot function has
> been fixed, we can, if Christoph agrees:

Instead of a new patch we could simply drop the patch

page-migration-replace-radix_tree_lookup_slot-with-radix_tree_lockup.patch

from Andrew's tree.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file writes
In-reply-To: <20071128192957.511EAB8310@localhost>
References: <20071128192957.511EAB8310@localhost>
Message-Id: <E1IxYuL-0001tu-8f@faramir.fjphome.nl>
From: Frans Pop <elendil@planet.nl>
Date: Thu, 29 Nov 2007 03:13:41 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

Two typos in comments.

Cheers,
FJP

Michael Rubin wrote:
> + * The flush tree organizes the dirtied_when keys with the rb_tree. Any
> + * inodes with a duplicate dirtied_when value are link listed together.
> This + * link list is sorted by the inode's i_flushed_when. When both the
> + * dirited_when and the i_flushed_when are indentical the order in the
> + * linked list determines the order we flush the inodes.

s/dirited_when/dirtied_when/

> + * Here is where we interate to find the next inode to process. The
> + * strategy is to first look for any other inodes with the same
> dirtied_when + * value. If we have already processed that node then we
> need to find + * the next highest dirtied_when value in the tree.

s/interate/iterate/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4ED106B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 20:25:16 -0400 (EDT)
Date: Wed, 29 Apr 2009 17:25:31 -0700 (PDT)
Message-Id: <20090429.172531.38936655.davem@davemloft.net>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, andi@firstfloor.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>
Date: Wed, 29 Apr 2009 22:09:48 +0100 (BST)

> Cc'ed DaveM and netdev, just in case they're surprised it was asking for
> so much, or disappointed it's not getting as much as it was asking for.

This is basically what should be happening, thanks for the note.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

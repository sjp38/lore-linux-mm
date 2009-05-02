Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E97AA6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 10:15:14 -0400 (EDT)
Message-ID: <49FC5554.2070802@redhat.com>
Date: Sat, 02 May 2009 10:14:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: cleanup the scan batching code
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org> <20090501012212.GA5848@localhost> <20090430194907.82b31565.akpm@linux-foundation.org> <20090502023125.GA29674@localhost>
In-Reply-To: <20090502023125.GA29674@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> The vmscan batching logic is twisting. Move it into a standalone
> function nr_scan_try_batch() and document it.  No behavior change.
> 
> CC: Nick Piggin <npiggin@suse.de>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

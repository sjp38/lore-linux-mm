Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAF2E6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 05:42:36 -0400 (EDT)
Subject: hwpoison fixes was Re: 2.6.32 -mm merge plans
From: Andi Kleen <andi@firstfloor.org>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
Date: Wed, 16 Sep 2009 11:42:36 +0200
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org> (Andrew Morton's message of "Tue, 15 Sep 2009 16:15:35 -0700")
Message-ID: <87fxancjjn.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

>
> mm-memory-failure-remove-config_unevictable_lru-config-option.patch
>   -> Andi

Integrated in the patch. Thanks.

>
> hwpoison-fix-uninitialized-warning.patch
>
>   -> Andi

Already added too

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

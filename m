Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 45B656B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 02:43:00 -0400 (EDT)
Message-ID: <4A7FC16B.20607@cs.helsinki.fi>
Date: Mon, 10 Aug 2009 09:42:51 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] mmotm: slqb correctly return value for notification handler
References: <20090807032345.GA15686@sli10-desk.sh.intel.com>
In-Reply-To: <20090807032345.GA15686@sli10-desk.sh.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Shaohua Li wrote:
> Correctly return value for notification handler. The bug causes other
> handlers are ignored and panic kernel.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Applied to slab.git, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

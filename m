Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 492336B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:19:04 -0400 (EDT)
Date: Wed, 26 May 2010 10:18:55 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFT PATCH 2/2] fb_defio: redo fix for non-dirty ptes
Message-ID: <20100526001854.GL20853@laptop>
References: <1274825820-10246-1-git-send-email-albert_herranz@yahoo.es>
 <1274825820-10246-2-git-send-email-albert_herranz@yahoo.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1274825820-10246-2-git-send-email-albert_herranz@yahoo.es>
Sender: owner-linux-mm@kvack.org
To: Albert Herranz <albert_herranz@yahoo.es>
Cc: jayakumar.lkml@gmail.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 12:17:00AM +0200, Albert Herranz wrote:
> As pointed by Nick Piggin, ->page_mkwrite provides a way to keep a page
> locked until the associated PTE is marked dirty.
> 
> Re-implement the fix by using this mechanism.
> 
> LKML-Reference: <20100525160149.GE20853@laptop>
> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>

Thanks for taking a look at this,

Acked-by: Nick Piggin <npiggin@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

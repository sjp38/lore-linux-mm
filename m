Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A7B256B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 19:40:20 -0400 (EDT)
Received: by gxk9 with SMTP id 9so2775432gxk.8
        for <linux-mm@kvack.org>; Tue, 25 May 2010 16:40:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1274825820-10246-2-git-send-email-albert_herranz@yahoo.es>
References: <1274825820-10246-1-git-send-email-albert_herranz@yahoo.es>
	 <1274825820-10246-2-git-send-email-albert_herranz@yahoo.es>
Date: Wed, 26 May 2010 07:40:13 +0800
Message-ID: <AANLkTikQ2cf_9P1DIVw5CV6NKHVhp10WyFBJW6J1yZY5@mail.gmail.com>
Subject: Re: [RFT PATCH 2/2] fb_defio: redo fix for non-dirty ptes
From: Jaya Kumar <jayakumar.lkml@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Albert Herranz <albert_herranz@yahoo.es>
Cc: npiggin@suse.de, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 6:17 AM, Albert Herranz <albert_herranz@yahoo.es> wrote:
> As pointed by Nick Piggin, ->page_mkwrite provides a way to keep a page
> locked until the associated PTE is marked dirty.
>
> Re-implement the fix by using this mechanism.
>
> LKML-Reference: <20100525160149.GE20853@laptop>
> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>

Looks good to me. Thanks.

Acked-by: Jaya Kumar <jayakumar.lkml@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

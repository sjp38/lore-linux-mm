Received: by wr-out-0506.google.com with SMTP id i30so555479wra
        for <linux-mm@kvack.org>; Wed, 27 Dec 2006 07:49:44 -0800 (PST)
Message-ID: <6d6a94c50612270749j77cd53a9mba6280e4129d9d5a@mail.gmail.com>
Date: Wed, 27 Dec 2006 23:49:43 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Page alignment issue
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

As for the buddy system, much of docs mention the physical address of
the first page frame of a block should be a multiple of the group
size. For example, the initial address of a 16-page-frame block should
be 16-page aligned. I happened to encounted an issue that the physical
addresss pf the block is not 4-page aligned(0x36c9000) while the order
of the block is 2. I want to know what out of buddy algorithm depend
on this feature? My problem seems to happen in
schedule()->context_switch() call, but so far I didn't figure out the
root cause.

Any clue or suggestion will be really appreciated!
Thanks,
-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

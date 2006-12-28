Received: by ug-out-1314.google.com with SMTP id s2so3879614uge
        for <linux-mm@kvack.org>; Wed, 27 Dec 2006 19:49:37 -0800 (PST)
Message-ID: <6d6a94c50612271949l66265cd4v4c63c1bdf3984417@mail.gmail.com>
Date: Thu, 28 Dec 2006 11:49:37 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Re: Page alignment issue
In-Reply-To: <6d6a94c50612270749j77cd53a9mba6280e4129d9d5a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50612270749j77cd53a9mba6280e4129d9d5a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On 12/27/06, Aubrey <aubreylee@gmail.com> wrote:
> As for the buddy system, much of docs mention the physical address of
> the first page frame of a block should be a multiple of the group
> size. For example, the initial address of a 16-page-frame block should
> be 16-page aligned. I happened to encounted an issue that the physical
> addresss pf the block is not 4-page aligned(0x36c9000) while the order
> of the block is 2. I want to know what out of buddy algorithm depend
> on this feature? My problem seems to happen in
> schedule()->context_switch() call, but so far I didn't figure out the
> root cause.

It seems nothing depend on this feature. the problem you encounted is
the kernel task stack should be 2-page aligned.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

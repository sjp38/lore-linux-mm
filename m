Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC8E06B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 00:39:40 -0500 (EST)
Message-ID: <4ECB3587.3020909@redhat.com>
Date: Tue, 22 Nov 2011 13:39:19 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
References: <1321612791-4764-1-git-send-email-amwang@redhat.com> <alpine.LSU.2.00.1111201300340.1264@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1111201300340.1264@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

ao? 2011a1'11ae??21ae?JPY 05:22, Hugh Dickins a??e??:
> On Fri, 18 Nov 2011, Cong Wang wrote:
>
>> It seems that systemd needs tmpfs to support fallocate,
>> see http://lkml.org/lkml/2011/10/20/275. This patch adds
>> fallocate support to tmpfs.
>>
>> As we already have shmem_truncate_range(), it is also easy
>> to add FALLOC_FL_PUNCH_HOLE support too.
>
> Thank you, this version looks much much nicer.
>
> I wouldn't call it bug-free (don't you need a page_cache_release
> after the unlock_page?), and I won't be reviewing it and testing it
> for a week or two - there's a lot about the semantics of fallocate
> and punch-hole that's not obvious, and I'll have to study the mail
> threads discussing them before checking your patch.

Yeah, sorry, I missed unlock_page()...

>
> First question that springs to mind (to which I shall easily find
> an answer): is it actually acceptable for fallocate() to return
> -ENOSPC when it has already completed a part of the work?

Ah, good point, I will fix this as what Christoph suggested.

>
> But so long as the details don't end up complicating this
> significantly, since we anyway want to regularize the punch-hole
> situation by giving tmpfs the same interface to it as other filesystems,
> I now think it would be a bit perverse to disallow the original
> fallocate functionality that you implement here in-kernel.
>

Ok, I think you mean you are fine to accept it now?

Anyway, thanks a lot for your comments!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

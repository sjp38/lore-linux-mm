Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 32D086B0068
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 08:32:19 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so6899349vbk.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 05:32:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1207301907010.3953@eggly.anvils>
References: <CAJd=RBDQ1J9UTWOK1x6XNYunFz36RsMnr1Om9HsQQ_Kp8P7RKQ@mail.gmail.com>
	<alpine.LSU.2.00.1207301907010.3953@eggly.anvils>
Date: Tue, 31 Jul 2012 20:32:18 +0800
Message-ID: <CAJd=RBBe2XHwe7T+EKoomFq1t2Me+VbJkz92Ow15FjEsPLJUow@mail.gmail.com>
Subject: Re: [RFC patch] vm: clear swap entry before copying pte
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Hugh,

On Tue, Jul 31, 2012 at 10:34 AM, Hugh Dickins <hughd@google.com> wrote:
> But I can see that the lack of reinitialization of entry.val here
> does raise doubt and confusion.  A better tidyup would be to remove
> the initialization of swp_entry_t entry from its onstack declaration,
> and do it at the again label instead.


I just want to avoid allocating page in add_swap_count_continuation()
for non clear reason, as you see, which is not a bug fix.

Thanks,
		Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB4A96B00D0
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 00:51:22 -0500 (EST)
Received: by yxm34 with SMTP id 34so4404772yxm.14
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 21:51:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101109142733.BC69.A69D9226@jp.fujitsu.com>
References: <AANLkTimXSSU7Mc05URg3HsONC4iyDTMVJdRxvQ1fNntH@mail.gmail.com> <20101109142733.BC69.A69D9226@jp.fujitsu.com>
From: Luke Hutchison <luke.hutch@gmail.com>
Date: Tue, 9 Nov 2010 00:50:40 -0500
Message-ID: <AANLkTikGC43B=+h5MNF665rFuRYfX4NQh6XyhuwxUT0A@mail.gmail.com>
Subject: Re: "BUG: soft lockup - CPU#0 stuck for 61s! [kswapd0:184]"
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 12:33 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> AFAIK, This isssue was already fixed by Mel.
>
> http://kerneltrap.org/mailarchive/linux-kernel/2010/10/27/4637977

Yes, based on where the CPU lockups were occurring
(zone_nr_free_pages, zone_watermark_ok), this fix does seem to address
the problem I described.  I assume the other lockup points
(_raw_spin_unlock_irqrestore, find_next_bit, sleeping_prematurely,
test_tsk_thread_flag) are also caused by the NR_FREE_PAGES problem?

Thank you for the link, I'll put it into the Fedora bug report and
hopefully a fix will be pushed out sometime soon.

Luke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

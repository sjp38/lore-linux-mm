Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C01056B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 03:55:17 -0400 (EDT)
Message-ID: <4FB0BA7B.1050200@kernel.org>
Date: Mon, 14 May 2012 16:55:39 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCHv2 00/16] [FS, MM, block, MMC]: eMMC High Priority Interrupt
 Feature
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com> <4FA8CF5E.1070202@kernel.org> <CANfBPZ-d-0FqY8Gruv+KDNoL3+FoQ68JEnxya5PydhY80x8yhA@mail.gmail.com> <4FA9BE10.1030007@kernel.org> <CAB+TZU-r6aYn8WRZjZ0DojxMTMoc5MSx7c93W0pAad1coscPwQ@mail.gmail.com>
In-Reply-To: <CAB+TZU-r6aYn8WRZjZ0DojxMTMoc5MSx7c93W0pAad1coscPwQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mani <manishrma@gmail.com>
Cc: linux-mmc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/14/2012 04:43 PM, mani wrote:

> Dear Kim,
> 
> I have a query here ..
> 
> 
>     My point is that it would be better for read to not preempt
>     write-for-page_reclaim.
>     And we can identify it by PG_reclaim. You can get the idea.
> 
> I think If there is no page available then no read will proceed.

> When read request comes it reclaim the pages (starts the write if

> syncable pages ) and get back after reclaiming the pages.
> Only then a read request will come to the MMC subsystem.

> And i think the reclaim algorithm will reclaim some substantial amount

> of pages at a time instead of a single page.
> So if we get few pages during the reclamation so there will be no
> problem in halting the another write ops for proceeding the reads ?
> 
> Can we think of a scenario when we are reclaiming the pages and write
> ops is going on where as a high priority read for the interrupt handler
> is pending ?
> 
> Please correct me if i am wrong.


For example, System can have lots of order-0 pages but little order-big pages.
In this case, for getting big contiguos memory, reclaimer should write out
dirty pages while it can handle order-0 page read request.


> 
> Thanks & Regards
> Manish



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

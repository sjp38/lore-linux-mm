Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AD4D36B00E7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 03:54:14 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so7406538vbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 00:54:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAB+TZU-r6aYn8WRZjZ0DojxMTMoc5MSx7c93W0pAad1coscPwQ@mail.gmail.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <4FA8CF5E.1070202@kernel.org> <CANfBPZ-d-0FqY8Gruv+KDNoL3+FoQ68JEnxya5PydhY80x8yhA@mail.gmail.com>
 <4FA9BE10.1030007@kernel.org> <CAB+TZU-r6aYn8WRZjZ0DojxMTMoc5MSx7c93W0pAad1coscPwQ@mail.gmail.com>
From: mani <manishrma@gmail.com>
Date: Mon, 14 May 2012 13:23:53 +0530
Message-ID: <CAB+TZU8jm_snfQoHRs_qpV_S7-g3Q9Ze2r1RjCYSftMxK6=Z6Q@mail.gmail.com>
Subject: Re: [PATCHv2 00/16] [FS, MM, block, MMC]: eMMC High Priority
 Interrupt Feature
Content-Type: multipart/alternative; boundary=20cf307cfe7a610c2404bffa64b2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mmc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, svenkatr@ti.com

--20cf307cfe7a610c2404bffa64b2
Content-Type: text/plain; charset=ISO-8859-1

Dear Kim,

I have a query here ..

>
> My point is that it would be better for read to not preempt
> write-for-page_reclaim.
> And we can identify it by PG_reclaim. You can get the idea.
>
> I think If there is no page available then no read will proceed.
When read request comes it reclaim the pages (starts the write if syncable
pages ) and get back after reclaiming the pages.
Only then a read request will come to the MMC subsystem.
And i think the reclaim algorithm will reclaim some substantial amount of
pages at a time instead of a single page.
So if we get few pages during the reclamation so there will be no problem
in halting the another write ops for proceeding the reads ?

Can we think of a scenario when we are reclaiming the pages and write ops
is going on where as a high priority read for the interrupt handler is
pending ?

Please correct me if i am wrong.

Thanks & Regards
Manish

--20cf307cfe7a610c2404bffa64b2
Content-Type: text/html; charset=ISO-8859-1

Dear Kim, <br><br>I have a query here .. <br><div class="im"><div class="gmail_quote"><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div>
<br>
</div>My point is that it would be better for read to not preempt write-for-page_reclaim.<br>
And we can identify it by PG_reclaim. You can get the idea.<br>
<br></blockquote></div></div>I think If there is no page available then no read will proceed. <br>When read request comes it reclaim the pages (starts the write if syncable pages ) and get back after reclaiming the pages. <br>


Only then a read request will come to the MMC subsystem. <br>And i think the reclaim algorithm will reclaim some substantial amount of pages at a time instead of a single page. <br>So
 if we get few pages during the reclamation so there will be no problem 
in halting the another write ops for proceeding the reads ? <br>
<br>Can we think of a scenario when we are reclaiming the pages and 
write ops is going on where as a high priority read for the interrupt 
handler is pending ?<br><br>Please correct me if i am wrong.<br><br>Thanks &amp; Regards<br>
Manish

--20cf307cfe7a610c2404bffa64b2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

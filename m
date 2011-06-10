Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C65CF6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 04:11:45 -0400 (EDT)
Received: by vxk20 with SMTP id 20so2674139vxk.14
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 01:11:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110610004331.13672278.akpm@linux-foundation.org>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
	<BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
	<BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
	<alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
	<20110601181918.GO3660@n2100.arm.linux.org.uk>
	<alpine.LFD.2.02.1106012043080.3078@ionos>
	<alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com>
	<alpine.LFD.2.02.1106012134120.3078@ionos>
	<4DF1C9DE.4070605@jp.fujitsu.com>
	<20110610004331.13672278.akpm@linux-foundation.org>
Date: Fri, 10 Jun 2011 12:11:42 +0400
Message-ID: <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, rientjes@google.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On 6/10/11, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 10 Jun 2011 16:38:06 +0900 KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> Subject: [PATCH] Revert "mm: fail GFP_DMA allocations when ZONE_DMA is not
>> configured"
>
> Confused.  We reverted this over a week ago.

Should one submit a patch adding a warning to GFP_DMA allocations
w/o ZONE_DMA, or the idea of the original patch is wrong?

-- 
With best wishes
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

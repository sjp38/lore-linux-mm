Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 234B76B0112
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:22:15 -0500 (EST)
Message-ID: <4CE40129.9060103@redhat.com>
Date: Wed, 17 Nov 2010 11:22:01 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>	<877hgmr72o.fsf@gmail.com>	<20101114140920.E013.A69D9226@jp.fujitsu.com>	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>	<1289810825.2109.469.camel@laptop>	<AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>	<4CE14848.2060805@redhat.com> <AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
In-Reply-To: <AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On 11/17/2010 05:16 AM, Minchan Kim wrote:

> Absolutely. But how about rsync's two touch?
> It can evict working set.
>
> I need the time for investigation.
> Thanks for the comment.

Maybe we could exempt MADV_SEQUENTIAL and FADV_SEQUENTIAL
touches from promoting the page to the active list?

Then we just need to make sure rsync uses fadvise properly
to keep the working set protected from rsync.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

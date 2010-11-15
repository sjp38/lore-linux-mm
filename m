Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 333F68D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:19:52 -0500 (EST)
Received: by gwj16 with SMTP id 16so2695357gwj.14
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 23:19:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101115160413.BF0F.A69D9226@jp.fujitsu.com>
References: <20101114140920.E013.A69D9226@jp.fujitsu.com>
	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
	<20101115160413.BF0F.A69D9226@jp.fujitsu.com>
Date: Mon, 15 Nov 2010 16:19:48 +0900
Message-ID: <AANLkTim0vCJkMoH5P0wCN9J6340rDsscyNBQ+R+_ph8m@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 4:09 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Because we have an alternative solution already. please try memcgroup :)
>>
>> I think memcg could be a solution of them but fundamental solution is
>> that we have to cure it in VM itself.
>> I feel it's absolutely absurd to enable and use memcg for amending it.
>>
>> I wonder what's the problem in Peter's patch 'drop behind'.
>> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
>>
>> Could anyone tell me why it can't accept upstream?
>
> I don't know the reason. And this one looks reasonable to me. I'm curious the above
> patch solve rsync issue or not.
> Minchan, have you tested it yourself?

Still yet. :)
If we all think it's reasonable, it would be valuable to adjust it
with current mmotm and see the effect.

>
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

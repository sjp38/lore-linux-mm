Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 73DA68D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 08:16:09 -0500 (EST)
Received: by iyi20 with SMTP id 20so3859892iyi.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 05:16:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D4DAF75.5090607@vflare.org>
References: <4D4D95C6.20505@vflare.org>
	<4D4DAF75.5090607@vflare.org>
Date: Sun, 6 Feb 2011 22:16:06 +0900
Message-ID: <AANLkTi=GhnOPxhvV87P3NTA-nES3zjxcTgSQjHQFC-w8@mail.gmail.com>
Subject: Re: zcache and kztmem combine to become the new zcache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Sun, Feb 6, 2011 at 5:13 AM, Nitin Gupta <ngupta@vflare.org> wrote:
> (Sorry, forgot to CC Dan)
>
> On 02/05/2011 01:24 PM, Nitin Gupta wrote:
>>
>> To zcache and kztmem users/reviewers --
>>
>> We, Nitin and Dan, have decided to combine zcache and kztmem and
>> call the resulting work as zcache.
>>
>> Since kztmem has evolved further than zcache, we have agreed to
>> use the kztmem code as the foundation for future work, so Dan will
>> resubmit the kztmem patchset soon with the name changed to zcache.
>>
>> Since both the "old zcache" and "new zcache" depend on the proposed
>> cleancache patch, Nitin and Dan will jointly work with the Linux
>> maintainers to support merging of cleancache, and also work together
>> on possibilities for merging frontswap and zram, since they serve
>> a similar function.
>>
>> If you have any questions or concerns, please ensure you reply
>> to both of us.
>>
>> Nitin Gupta and Dan Magenheimer

Good to hear! and sorry for not giving the time to review it recently.
I am looking forward to seeing the feature. :)

Thanks.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D3936B00FB
	for <linux-mm@kvack.org>; Wed, 13 May 2009 08:11:56 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so279404ywm.26
        for <linux-mm@kvack.org>; Wed, 13 May 2009 05:12:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	 <87r5ytl0nn.fsf@basil.nowhere.org>
	 <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com>
	 <20090513113817.GO19296@one.firstfloor.org>
	 <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com>
Date: Wed, 13 May 2009 21:12:06 +0900
Message-ID: <28c262360905130512j6b6bab9dj847e17840120d8e9@mail.gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
	submenu
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 8:58 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>> In past days, I proposed this. but Minchan found this config bloat kernel 7kb
>>> and he claim embedded guys should have selectable chance. I agreed it.
>>
>> Well there's lots of code in the kernel and 7k doesn't seem worth bothering.
>> If you just save two pages of memory somewhere you can save more.
>>
>>> Is this enough explanation?
>>
>> It's not a very good one.
>>
>> I would propose to just remove it or at least hide it completely
>> and only make it dependent on CONFIG_MMU inside Kconfig.
>
> hm, if minchan ack this, I can remove this option completely.

In fact, I expected this feature has to be disable with default.
But, David and Hannes already acked with enable with default.

It means they don't have a size concern, too.
Hmm. If I don't misunderstood their thought, I agree Andi's suggestion.

Thanks for good discussion. Andi!

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

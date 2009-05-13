Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 589716B00EC
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:18:22 -0400 (EDT)
Received: by gxk20 with SMTP id 20so1062376gxk.14
        for <linux-mm@kvack.org>; Wed, 13 May 2009 04:18:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87r5ytl0nn.fsf@basil.nowhere.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	 <87r5ytl0nn.fsf@basil.nowhere.org>
Date: Wed, 13 May 2009 20:18:38 +0900
Message-ID: <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
	submenu
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

2009/5/13 Andi Kleen <andi@firstfloor.org>:
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:
>
>> Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
>>
>> Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
>> used only embedded people.
>> Thus, moving it into embedded submenu is better.
>
> Is there are any reason it cannot be just made unconditional unless
> CONFIG_MMU is disabled. It was never clear to me why this was a config
> option at all.

In past days, I proposed this. but Minchan found this config bloat kernel 7kb
and he claim embedded guys should have selectable chance. I agreed it.

Is this enough explanation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

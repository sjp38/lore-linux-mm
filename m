Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E12396B00FA
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:57:26 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so274969yxh.26
        for <linux-mm@kvack.org>; Wed, 13 May 2009 04:58:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090513113817.GO19296@one.firstfloor.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	 <87r5ytl0nn.fsf@basil.nowhere.org>
	 <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com>
	 <20090513113817.GO19296@one.firstfloor.org>
Date: Wed, 13 May 2009 20:58:20 +0900
Message-ID: <2f11576a0905130458x2e56e952ga47216da42b30906@mail.gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
	submenu
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

>> In past days, I proposed this. but Minchan found this config bloat kernel 7kb
>> and he claim embedded guys should have selectable chance. I agreed it.
>
> Well there's lots of code in the kernel and 7k doesn't seem worth bothering.
> If you just save two pages of memory somewhere you can save more.
>
>> Is this enough explanation?
>
> It's not a very good one.
>
> I would propose to just remove it or at least hide it completely
> and only make it dependent on CONFIG_MMU inside Kconfig.

hm, if minchan ack this, I can remove this option completely.
but I dislike dpend on CONFIG_MMU. it because

1. this featuren don't depend CONFIG_MMU. that's bogus.
2. I don't test !MMU easily rather than MMU. IOW it make code quality risk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

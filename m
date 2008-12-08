Received: by wa-out-1112.google.com with SMTP id j37so573943waf.22
        for <linux-mm@kvack.org>; Mon, 08 Dec 2008 06:30:40 -0800 (PST)
Message-ID: <2f11576a0812080630j4327dbbgf0aa0e332156d229@mail.gmail.com>
Date: Mon, 8 Dec 2008 23:30:40 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
In-Reply-To: <1228744588.22647.32.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1228482500.8392.15.camel@t60p> <1228509818.12681.21.camel@nimitz>
	 <20081207133450.53D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1228744588.22647.32.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, gerald.schaefer@de.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

>> Lee, Could you read this thread and explain why you add ifdef CONFIG_UNEVICTABLE_LRU?
>> I am not sure about that Dave's proposal is safe change. (but I guess he is right)
>
> I added that back in Patch 17/25 "Mlocked Pages are
> non-reclaimable" [before nonreclaimable became unevictable".  I did this
> because "lru_add_drain_all()" was only used by numa code prior to this,
> and was under #ifdef CONFIG_NUMA".  I called lru_add_drain_all() from
> __mlock_vma_pages_range() [since removed] and I wanted the
> nonreclaimable/unevictable mlocked pages feature to be independent of
> numa.  So, I had to ensure that we defined the function for
> nonreclaimable/unevictable lru as well as numa.
>
> Now it appears that hotplug and memcg also depend on
> lru_add_drain_all(), so making it depend on 'SMP looks reasonable to me.

Thanks a lot.

I'll make that patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CABA16B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:13:18 -0400 (EDT)
Received: by mail-vb0-f50.google.com with SMTP id l1so4275673vba.9
        for <linux-mm@kvack.org>; Mon, 14 May 2012 17:13:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337034892.8512.652.camel@edumazet-glaptop>
References: <1337034597-1826-1-git-send-email-pshelar@nicira.com>
	<1337034892.8512.652.camel@edumazet-glaptop>
Date: Mon, 14 May 2012 17:13:17 -0700
Message-ID: <CALnjE+qGpJCf6FOb37DjJfh5qHfJuF7DBmbqDNYR7KJ3Ux41Uw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix slab->page _count corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Mon, May 14, 2012 at 3:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-05-14 at 15:29 -0700, Pravin B Shelar wrote:
>> On arches that do not support this_cpu_cmpxchg_double slab_lock is used
>> to do atomic cmpxchg() on double word which contains page->_count.
>> page count can be changed from get_page() or put_page() without taking
>> slab_lock. That corrupts page counter.
>>
>> Following patch fixes it by moving page->_count out of cmpxchg_double
>> data. So that slub does no change it while updating slub meta-data in
>> struct page.
>
> I say again : Page is owned by slub, so get_page() or put_page() is not
> allowed ?
>
This is already done in multiple subsystem in Linux kernel. e.g.
ocfs, xfs, etc.
So object from slab can be passed to IO using DMA. I don't think this
rule you referring to is enforced anywhere.

Thanks,
Pravin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

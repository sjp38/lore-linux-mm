Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CDB4B6B0068
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 14:09:56 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so2173917bkc.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 11:09:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121211183937.GA5168@cmpxchg.org>
References: <1355213523-15698-1-git-send-email-linfeng@cn.fujitsu.com>
	<20121211183937.GA5168@cmpxchg.org>
Date: Tue, 11 Dec 2012 11:09:54 -0800
Message-ID: <CAE9FiQVtsd90x3cpaZWK+oVUydApb9YVON3LNV1+cP9_0uCWzw@mail.gmail.com>
Subject: Re: [PATCH] mm/bootmem.c: remove unused wrapper function reserve_bootmem_generic()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, hpa@zytor.com, davem@davemloft.net, eric.dumazet@gmail.com, tj@kernel.org, shangw@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 11, 2012 at 10:39 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Dec 11, 2012 at 04:12:03PM +0800, Lin Feng wrote:
>> Wrapper fucntion reserve_bootmem_generic() currently have no caller,
>> so clean it up.
>>
>> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

yes, this is leftover from

commit 774ea0bcb27f57b6fd521b3b6c43237782fed4b9
Date:   Wed Aug 25 13:39:18 2010 -0700

    x86: Remove old bootmem code

    Requested by Ingo, Thomas and HPA.

    The old bootmem code is no longer necessary, and the transition is
    complete.  Remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

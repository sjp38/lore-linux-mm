Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 940F76B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 02:11:38 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so3384773pbb.22
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 23:11:38 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ug9si20231467pab.253.2014.04.20.23.11.36
        for <linux-mm@kvack.org>;
        Sun, 20 Apr 2014 23:11:37 -0700 (PDT)
Message-ID: <5354B627.2090201@cn.fujitsu.com>
Date: Mon, 21 Apr 2014 14:09:43 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/swap: cleanup *lru_cache_add* functions
References: <1397835565-6411-1-git-send-email-nasa4836@gmail.com> <53546DA3.2080709@cn.fujitsu.com> <CAHz2CGWVo9ZXDY7S5_OU-6C1syiMuXX4qCpMUM+YCMkDUcSSZg@mail.gmail.com>
In-Reply-To: <CAHz2CGWVo9ZXDY7S5_OU-6C1syiMuXX4qCpMUM+YCMkDUcSSZg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, shli@kernel.org, bob.liu@oracle.com, sjenning@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, aquini@redhat.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, khalid.aziz@oracle.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/21/2014 12:02 PM, Jianyu Zhan wrote:
> Hi,  Yanfei,
> 
> On Mon, Apr 21, 2014 at 9:00 AM, Zhang Yanfei
> <zhangyanfei@cn.fujitsu.com> wrote:
>> What should be exported?
>>
>> lru_cache_add()
>> lru_cache_add_anon()
>> lru_cache_add_file()
>>
>> It seems you only export lru_cache_add_file() in the patch.
> 
> Right, lru_cache_add_anon() is only used by VM code, so it should not
> be exported.
> 
> lru_cache_add_file() and lru_cache_add() are supposed to be used by
> vfs ans fs code.
> 
> But  now only lru_cache_add_file() is  used by CIFS and FUSE, which
> both could be
> built as module, so it must be exported;  and lru_cache_add() has now
> no module users,
> so as Rik suggests, it is unexported too.
> 

OK. So The sentence in the patch log confused me:

[ However, lru_cache_add() is supposed to
be used by vfs, or whatever others, but it is not exported.]

otherwise, 
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Thanks.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

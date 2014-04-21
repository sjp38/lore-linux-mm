Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 856486B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 00:03:23 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so3517090iec.35
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 21:03:23 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id j3si6570882igv.37.2014.04.20.21.03.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Apr 2014 21:03:22 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so1369759igb.5
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 21:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53546DA3.2080709@cn.fujitsu.com>
References: <1397835565-6411-1-git-send-email-nasa4836@gmail.com> <53546DA3.2080709@cn.fujitsu.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Mon, 21 Apr 2014 12:02:42 +0800
Message-ID: <CAHz2CGWVo9ZXDY7S5_OU-6C1syiMuXX4qCpMUM+YCMkDUcSSZg@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: cleanup *lru_cache_add* functions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, shli@kernel.org, bob.liu@oracle.com, sjenning@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, aquini@redhat.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, khalid.aziz@oracle.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,  Yanfei,

On Mon, Apr 21, 2014 at 9:00 AM, Zhang Yanfei
<zhangyanfei@cn.fujitsu.com> wrote:
> What should be exported?
>
> lru_cache_add()
> lru_cache_add_anon()
> lru_cache_add_file()
>
> It seems you only export lru_cache_add_file() in the patch.

Right, lru_cache_add_anon() is only used by VM code, so it should not
be exported.

lru_cache_add_file() and lru_cache_add() are supposed to be used by
vfs ans fs code.

But  now only lru_cache_add_file() is  used by CIFS and FUSE, which
both could be
built as module, so it must be exported;  and lru_cache_add() has now
no module users,
so as Rik suggests, it is unexported too.


Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

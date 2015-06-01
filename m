Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 172B76B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 07:14:57 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so81817594qko.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 04:14:56 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id l4si12676079qge.125.2015.06.01.04.14.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 04:14:56 -0700 (PDT)
Received: by qcej9 with SMTP id j9so2941681qce.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 04:14:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150529143755.35e070822d62cf39119aac13@linux-foundation.org>
References: <1432912338-16775-1-git-send-email-ddstreet@ieee.org> <20150529143755.35e070822d62cf39119aac13@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 1 Jun 2015 07:14:34 -0400
Message-ID: <CALZtONAN=7q3bOOq3mJvRDwydnZ-3fQrxB+BOq_VgiY4Pmr+hg@mail.gmail.com>
Subject: Re: [PATCH] zpool: add zpool_has_pool()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, May 29, 2015 at 5:37 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 29 May 2015 11:12:18 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add zpool_has_pool() function, indicating if the specified type of zpool
>> is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
>> available, without actually trying to allocate it, similar to
>> crypto_has_alg().
>>
>> ...
>>
>> +bool zpool_has_pool(char *type);
>
> This has no callers.

Yes, I have a few patches coming up for zswap, that use this.  I was
trying to get the simple patches in first, but I can include this in
the patch series that uses it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

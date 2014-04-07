Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 431E96B0037
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 04:26:47 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id c11so4514024lbj.12
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 01:26:46 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pr4si11551936lbc.198.2014.04.07.01.26.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 01:26:45 -0700 (PDT)
Message-ID: <5342613E.2090900@parallels.com>
Date: Mon, 7 Apr 2014 12:26:38 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/3] lockdep: mark rwsem_acquire_read as recursive
References: <cover.1396779337.git.vdavydov@parallels.com> <8c6473e959a4557d8622a6d7ff24888cb3f7512d.1396779337.git.vdavydov@parallels.com> <20140407081336.GC11096@twins.programming.kicks-ass.net>
In-Reply-To: <20140407081336.GC11096@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Ingo Molnar <mingo@redhat.com>

On 04/07/2014 12:13 PM, Peter Zijlstra wrote:
> On Sun, Apr 06, 2014 at 07:33:51PM +0400, Vladimir Davydov wrote:
>> rw_semaphore implementation allows recursing calls to down_read, but
>> lockdep thinks that it doesn't. As a result, it will complain
>> false-positively, e.g. if we do not observe some predefined locking
>> order when taking an rw semaphore for reading and a mutex.
>>
>> This patch makes lockdep think rw semaphore is read-recursive, just like
>> rw spin lock.
> Uhm no rwsem isn't read recursive.

Yeah, I was mistaken and is already reworking my set. Please sorry for
the noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

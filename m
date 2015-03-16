Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id BC9C76B0072
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:18:07 -0400 (EDT)
Received: by lbcds1 with SMTP id ds1so34539188lbc.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:18:07 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id n6si8478520laf.170.2015.03.16.09.18.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 09:18:06 -0700 (PDT)
Message-ID: <5507023B.4090905@yandex-team.ru>
Date: Mon, 16 Mar 2015 19:18:03 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: rcu-protected get_mm_exe_file()
References: <20150316131257.32340.36600.stgit@buzz>	 <20150316140720.GA1859@redhat.com> <1426517419.28068.118.camel@stgolabs.net>
In-Reply-To: <1426517419.28068.118.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On 16.03.2015 17:50, Davidlohr Bueso wrote:
> On Mon, 2015-03-16 at 15:07 +0100, Oleg Nesterov wrote:
>> 	3. and we can remove down_write(mmap_sem) from prctl paths.
>>
>> 	   Actually we can do this even without xchg() above, but we might
>> 	   want to kill MMF_EXE_FILE_CHANGED and test_and_set_bit() check.
>
> Yeah I was waiting for security folks input about this, otherwise this
> still doesn't do it for me as we still have to deal with mmap_sem.
>

Why? mm->flags are updated atomically. mmap_sem isn't required here.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

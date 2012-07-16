Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id A68B36B0083
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:59:19 -0400 (EDT)
Received: by yenr5 with SMTP id r5so6352963yen.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:59:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87394rr4dl.fsf@erwin.mina86.com>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
	<1342455272-32703-2-git-send-email-js1304@gmail.com>
	<87394rr4dl.fsf@erwin.mina86.com>
Date: Tue, 17 Jul 2012 02:59:18 +0900
Message-ID: <CAAmzW4OZZgPKrffdvMmEgpzF=7C9mJTkEhBfjJ5G7Q15xLzv2g@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: fix possible incorrect return value of
 migrate_pages() syscall
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@tlen.pl>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>, Christoph Lameter <cl@linux.com>

2012/7/17 Michal Nazarewicz <mina86@tlen.pl>:
> Joonsoo Kim <js1304@gmail.com> writes:
>> do_migrate_pages() can return the number of pages not migrated.
>> Because migrate_pages() syscall return this value directly,
>> migrate_pages() syscall may return the number of pages not migrated.
>> In fail case in migrate_pages() syscall, we should return error value.
>> So change err to -EIO
>>
>> Additionally, Correct comment above do_migrate_pages()
>>
>> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>> Cc: Sasha Levin <levinsasha928@gmail.com>
>> Cc: Christoph Lameter <cl@linux.com>
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Thanks.

When I resend with changing -EIO to -EBUSY,
could I include "Acked-by: Michal Nazarewicz <mina86@mina86.com>"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

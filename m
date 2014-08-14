Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 28A1E6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 11:32:38 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1761819pdj.14
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 08:32:37 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id dh3si4557641pdb.125.2014.08.14.08.32.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 08:32:37 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so1764118pdj.2
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 08:32:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONDB5q56f1TUHgqbiJ4ZaP6Yk=GcNQw9DhvLhNyExdfQ4w@mail.gmail.com>
References: <1407978746-20587-1-git-send-email-minchan@kernel.org>
	<1407978746-20587-3-git-send-email-minchan@kernel.org>
	<CALZtONDB5q56f1TUHgqbiJ4ZaP6Yk=GcNQw9DhvLhNyExdfQ4w@mail.gmail.com>
Date: Thu, 14 Aug 2014 11:32:36 -0400
Message-ID: <CAFdhcLQ11MnF7Py+X1wrJMiu0L15-JrV883oYGopdz1oag0njQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] zram: add mem_used_max via sysfs
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

On Thu, Aug 14, 2014 at 11:09 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Wed, Aug 13, 2014 at 9:12 PM, Minchan Kim <minchan@kernel.org> wrote:
>> -       if (zram->limit_bytes &&
>> -               zs_get_total_size_bytes(meta->mem_pool) > zram->limit_bytes) {
>> +       total_bytes = zs_get_total_size_bytes(meta->mem_pool);
>> +       if (zram->limit_bytes && total_bytes > zram->limit_bytes) {
>
> do you need to take the init_lock to read limit_bytes here?  It could
> be getting changed between these checks...

There is no real danger in freeing with an error.
It is more timing than a race.

The max calculation is still ok because committed allocations are
added atomically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

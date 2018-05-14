Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1EC96B0008
	for <linux-mm@kvack.org>; Mon, 14 May 2018 15:24:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id c24-v6so4450075lfh.10
        for <linux-mm@kvack.org>; Mon, 14 May 2018 12:24:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 142-v6sor2266583ljj.43.2018.05.14.12.24.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 12:24:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <bd9f9811-bec7-5394-30d4-5db833ecf5b4@kernel.dk>
References: <20180509013358.16399-1-kent.overstreet@gmail.com> <bd9f9811-bec7-5394-30d4-5db833ecf5b4@kernel.dk>
From: Kent Overstreet <kent.overstreet@gmail.com>
Date: Mon, 14 May 2018 15:24:53 -0400
Message-ID: <CAC7rs0vTjxkiM3yUuReO848_i7SOD7ZD4NOHcP9bFoxK706-Bg@mail.gmail.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>

Thanks!

On Mon, May 14, 2018 at 3:24 PM, Jens Axboe <axboe@kernel.dk> wrote:
> On 5/8/18 7:33 PM, Kent Overstreet wrote:
>>  - Add separately allowed mempools, biosets: bcachefs uses both all over the
>>    place
>>
>>  - Bit of utility code - bio_copy_data_iter(), zero_fill_bio_iter()
>>
>>  - bio_list_copy_data(), the bi_next check - defensiveness because of a bug I
>>    had fun chasing down at one point
>>
>>  - add some exports, because bcachefs does dio its own way
>>  - show whether fua is supported in sysfs, because I don't know of anything that
>>    exports whether the _block layer_ specifically thinks fua is supported.
>
> Thanks Kent, applied for 4.18 with the update patch 1.
>
> --
> Jens Axboe
>

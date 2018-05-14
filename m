Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 343636B0006
	for <linux-mm@kvack.org>; Mon, 14 May 2018 15:24:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c82-v6so16036838itg.1
        for <linux-mm@kvack.org>; Mon, 14 May 2018 12:24:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x186-v6sor6958536iof.275.2018.05.14.12.24.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 12:24:05 -0700 (PDT)
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <bd9f9811-bec7-5394-30d4-5db833ecf5b4@kernel.dk>
Date: Mon, 14 May 2018 13:24:02 -0600
MIME-Version: 1.0
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On 5/8/18 7:33 PM, Kent Overstreet wrote:
>  - Add separately allowed mempools, biosets: bcachefs uses both all over the
>    place
> 
>  - Bit of utility code - bio_copy_data_iter(), zero_fill_bio_iter()
> 
>  - bio_list_copy_data(), the bi_next check - defensiveness because of a bug I
>    had fun chasing down at one point
> 
>  - add some exports, because bcachefs does dio its own way
>  - show whether fua is supported in sysfs, because I don't know of anything that
>    exports whether the _block layer_ specifically thinks fua is supported.

Thanks Kent, applied for 4.18 with the update patch 1.

-- 
Jens Axboe

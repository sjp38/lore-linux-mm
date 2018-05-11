Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 672696B06D2
	for <linux-mm@kvack.org>; Fri, 11 May 2018 17:13:42 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id i1-v6so3902664pld.11
        for <linux-mm@kvack.org>; Fri, 11 May 2018 14:13:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t30-v6sor1204047pgo.37.2018.05.11.14.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 14:13:41 -0700 (PDT)
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <b3970608-95dd-3d4f-140c-3d7cbd12cf8d@kernel.dk>
Date: Fri, 11 May 2018 15:13:38 -0600
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

Looked over the series, and looks like both good cleanups and optimizations.
If we can get the mempool patch sorted, I can apply this for 4.18.

-- 
Jens Axboe

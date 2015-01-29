Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 885136B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 02:08:38 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so35466443pab.5
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:08:38 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id hp4si4165689pbb.9.2015.01.28.23.08.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 23:08:37 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so35507938pad.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:08:37 -0800 (PST)
Date: Thu, 29 Jan 2015 16:08:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129070835.GD2555@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150129063505.GA32331@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (01/29/15 15:35), Minchan Kim wrote:
>
> As you told, the data was not stable.
>
yes. fread test was always slower, and the rest was mostly slower.


> Anyway, when I read down_read implementation, it's one atomic instruction.
> Hmm, it seems te be better for srcu_read_lock which does more things.
>
srcu looks havier, agree.

> But I guessed most of overhead are from [de]compression, memcpy, clear_page
> That's why I guessed we don't have measurable difference from that.
> What's the data pattern if you use iozone?

by "data pattern" you mean usage scenario? well, I usually use zram for
`make -jX', where X=[4..N]. so N concurrent read-write ops scenario.

	-ss

> I guess it's really simple pattern compressor can do fast. I used /dev/sda
> for dd write so more realistic data. Anyway, if we has 10% regression even if
> the data is simple, I never want to merge it.
> I will test it carefully and if it turns out lots regression,
> surely, I will not go with this and send the original patch again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

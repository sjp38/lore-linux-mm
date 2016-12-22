Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6980E6B03EF
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 20:32:16 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n189so21839859pga.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 17:32:16 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g84si28719274pfg.42.2016.12.21.17.32.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 17:32:15 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id y68so11546787pfb.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 17:32:15 -0800 (PST)
Date: Thu, 22 Dec 2016 10:32:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v4 2/3] zram: revalidate disk under init_lock
Message-ID: <20161222013223.GD644@jagdpanzerIV.localdomain>
References: <1482366980-3782-1-git-send-email-minchan@kernel.org>
 <1482366980-3782-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482366980-3782-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, "[4.7+]" <stable@vger.kernel.org>

On (12/22/16 09:36), Minchan Kim wrote:
> [1] moved revalidate_disk call out of init_lock to avoid lockdep
> false-positive splat. However, [2] remove init_lock in IO path
> so there is no worry about lockdep splat. So, let's restore it.
> This patch need to set BDI_CAP_STABLE_WRITES atomically in
> next patch.
> 
> [1] b4c5c60920e3: zram: avoid lockdep splat by revalidate_disk
> [2] 08eee69fcf6b: zram: remove init_lock in zram_make_request
> 
> Fixes: da9556a2367c ("zram: user per-cpu compression streams")
> Cc: <stable@vger.kernel.org> [4.7+]
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

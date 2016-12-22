Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A11D76B03ED
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 20:31:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so415191890pgi.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 17:31:27 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id z128si5298292pfz.92.2016.12.21.17.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 17:31:26 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id w68so12159887pgw.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 17:31:26 -0800 (PST)
Date: Thu, 22 Dec 2016 10:31:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v4 3/3] zram: support BDI_CAP_STABLE_WRITES
Message-ID: <20161222013134.GC644@jagdpanzerIV.localdomain>
References: <1482366980-3782-1-git-send-email-minchan@kernel.org>
 <1482366980-3782-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482366980-3782-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, "[4.7+]" <stable@vger.kernel.org>

On (12/22/16 09:36), Minchan Kim wrote:
> zram has used per-cpu stream feature from v4.7.
> It aims for increasing cache hit ratio of scratch buffer for
> compressing. Downside of that approach is that zram should ask
> memory space for compressed page in per-cpu context which requires
> stricted gfp flag which could be failed. If so, it retries to
> allocate memory space out of per-cpu context so it could get memory
> this time and compress the data again, copies it to the memory space.
> 
> In this scenario, zram assumes the data should never be changed
> but it is not true without stable page support. So, If the data is
> changed under us, zram can make buffer overrun so that zsmalloc
> free object chain is broken so system goes crash like below
> https://bugzilla.suse.com/show_bug.cgi?id=997574
> 
> This patch adds BDI_CAP_STABLE_WRITES to zram for declaring
> "I am block device needing *stable write*".
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

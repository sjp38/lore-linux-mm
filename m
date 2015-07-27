Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 97FF06B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:17:28 -0400 (EDT)
Received: by laah7 with SMTP id h7so51162945laa.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:17:28 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id dl8si15501318lad.72.2015.07.27.08.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 08:17:27 -0700 (PDT)
Date: Mon, 27 Jul 2015 18:17:12 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -next] mm: Fix build breakage seen if MMU_NOTIFIER is not
 configured
Message-ID: <20150727151712.GQ8100@esperanza>
References: <1438009343-25468-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1438009343-25468-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>

On Mon, Jul 27, 2015 at 08:02:23AM -0700, Guenter Roeck wrote:

> fs/proc/page.c: In function 'kpageidle_clear_pte_refs_one':
> fs/proc/page.c:341:4: error:
> 	implicit declaration of function 'pmdp_clear_young_notify'
> fs/proc/page.c:347:4: error:
> 	implicit declaration of function 'ptep_clear_young_notify'

The issue has already been reported and fixed, see
http://www.spinics.net/lists/linux-mm/msg92023.html

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

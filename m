Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A4D6C6B0038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 02:55:04 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so722288pad.9
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 23:55:04 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qi8si13477481pac.31.2014.12.18.23.55.01
        for <linux-mm@kvack.org>;
        Thu, 18 Dec 2014 23:55:02 -0800 (PST)
Message-ID: <5493D9CE.5040001@lge.com>
Date: Fri, 19 Dec 2014 16:54:54 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [RFC] background zero-set page for device
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, =?EUC-KR?B?wMywx8ij?= <gunho.lee@lge.com>, Minchan Kim <minchan@kernel.org>, =?EUC-KR?B?J7Howdg=?= =?EUC-KR?B?vPYn?= <iamjoonsoo.kim@lge.com>


There was some discussion to create zero-set pages in background like this:
https://lkml.org/lkml/2004/10/30/73

I'm understand that it is not good for performance.

But I think it can help for a device in my platform.
I'm sorry I can't tell what it is.
But the device needs many zero-set pages, up to several MB,
so that device driver has a loop to calls alloc_page, memset(p, 0, PAGE_SIZE) and cache flush&invalidate.
And the device uses the pages and returns it to kernel. Kernel reads data in the page.

In this case, memset(0) must be done.
I think, if memset(0) is done at idle time, it can remove memset calling of ddk.

Is there any device that needs many zero-set pages?
Can backgound zero-setting page be good for the device?

-- 
Thanks,
Gioh Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

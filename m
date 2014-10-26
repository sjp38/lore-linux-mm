Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 69E016B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:41:54 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so3287703pad.31
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 18:41:54 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id fr3si7440932pbd.34.2014.10.25.18.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 18:41:53 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so3501124pdj.5
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 18:41:53 -0700 (PDT)
Date: Sun, 26 Oct 2014 10:41:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] zram: make max_used_pages reset work correctly
Message-ID: <20141026014143.GA3328@gmail.com>
References: <000001cff035$c060dc60$41229520$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cff035$c060dc60$41229520$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

Hello,

On Sat, Oct 25, 2014 at 05:25:11PM +0800, Weijie Yang wrote:
> The commit 461a8eee6a ("zram: report maximum used memory") introduces a new
> knob "mem_used_max" in zram.stats sysfs, and wants to reset it via write 0
> to the sysfs interface.
> 
> However, the current code cann't reset it correctly, so let's fix it.

We wanted to reset it to current used total memory, not 0.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

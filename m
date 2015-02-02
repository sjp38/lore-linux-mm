Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC1B6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 00:28:18 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so77780970pac.13
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:28:18 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id wp3si22478042pab.1.2015.02.01.21.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 21:28:17 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so77838564pab.0
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:28:17 -0800 (PST)
Date: Mon, 2 Feb 2015 14:28:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202052816.GA760@swordfish>
References: <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
 <20150202024405.GD6402@blaptop>
 <20150202040124.GE6977@swordfish>
 <20150202042847.GG6402@blaptop>
 <20150202050912.GA443@swordfish>
 <20150202051805.GI6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202051805.GI6402@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/02/15 14:18), Minchan Kim wrote:
> Everything are fixed. Ready to send a patch.
> But before sending, hope we fix umount race issue first.
> 

Thanks a lot, Minchan!


OK, surely I don't mind to fix the umount race first, I just didn't want
to interrupt you in the middle of locking rework. the race is hardly
possible, but still.


I didn't review Ganesh's patch yet, I'll try to find some time to take a
look later this day.

I'm also planning to send a small `struct zram' cleanup patch by the end
of this day.


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

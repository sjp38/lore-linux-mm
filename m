Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6439D6B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:48:21 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so4255374pad.27
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:48:21 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ud1si6441603pbc.84.2014.11.20.22.48.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 22:48:20 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so4262016pab.0
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:48:19 -0800 (PST)
Date: Fri, 21 Nov 2014 06:48:49 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm/zsmalloc: remove unnecessary check
Message-ID: <20141121064849.GA17181@gmail.com>
References: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
 <20141121035442.GB10123@bbox>
 <CADAEsF975+a6Y5dcEu1B2OscQ5JaxD+ZQ1jnFOJ115BXgMqULA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF975+a6Y5dcEu1B2OscQ5JaxD+ZQ1jnFOJ115BXgMqULA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Nov 21, 2014 at 01:33:26PM +0800, Ganesh Mahendran wrote:
> Hello
> 
> 2014-11-21 11:54 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > On Thu, Nov 20, 2014 at 09:21:56PM +0800, Mahendran Ganesh wrote:
> >> ZS_SIZE_CLASSES is calc by:
> >>   ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)
> >>
> >> So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
> >>   size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
> >> will not be greater than ZS_MAX_ALLOC_SIZE
> >>
> >> This patch removes the unnecessary check.
> >
> > It depends on ZS_MIN_ALLOC_SIZE.
> > For example, we would change min to 8 but MAX is still 4096.
> > ZS_SIZE_CLASSES is (4096 - 8) / 16 + 1 = 256 so 8 + 255 * 16 = 4088,
> > which exceeds the max.
> Here, 4088 is less than MAX(4096).
> 
> ZS_SIZE_CLASSES = (MAX - MIN) / Delta + 1
> So, I think the value of
>     MIN + (ZS_SIZE_CLASSES - 1) * Delta =
>     MIN + ((MAX - MIN) / Delta) * Delta =
>     MAX
> will not exceed the MAX

You're right. It was complext math for me.
I should go back to elementary school.

Thanks!

Acked-by: Minchan Kim <minchan@kernel.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

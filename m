Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 884096B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 23:01:59 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so11483866pab.6
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 20:01:59 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zm3si19736353pac.97.2014.07.28.20.01.56
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 20:01:58 -0700 (PDT)
Date: Tue, 29 Jul 2014 12:01:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Patch: zram add compressionratio in sysfs interface
Message-ID: <20140729030158.GB22707@bbox>
References: <CAG6enPwuD2_6U=iELn9C7gMzxre0V-VYmxP14R-qW3sMNddvCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAG6enPwuD2_6U=iELn9C7gMzxre0V-VYmxP14R-qW3sMNddvCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yogesh Gaur <yogeshgaur.83@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org

Hello,

On Wed, Jul 23, 2014 at 02:58:00PM +0530, Yogesh Gaur wrote:
> Hello All,
> 
> Please find attached patch which adds new entry in existing zram device
> sysfs interface, this interface shows compression ratio for asked zram
> device.
> Sysfs interface for 'orig_data_size' and 'mem_used_total' already present,
> 'compression_ratio' would be orig_data_size divided by mem_used_total.
> 
> Please check patch.

Pz, do it in userspace.

> 
> --
> Regards,
> Yogesh Gaur.



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

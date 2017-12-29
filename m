Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A77E56B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 04:21:55 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i7so24771492plt.3
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 01:21:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor12072981plw.35.2017.12.29.01.21.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Dec 2017 01:21:54 -0800 (PST)
Date: Fri, 29 Dec 2017 18:21:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zram: better utilization of zram swap space
Message-ID: <20171229092149.GA764@jagdpanzerIV>
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
 <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
 <20171227062946.GA11295@bgram>
 <20171227071056.GA471@jagdpanzerIV>
 <20171228000004.GB10532@bbox>
 <20171229072656.GA10366@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229072656.GA10366@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, gopi.st@samsung.com
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com

Hello,

On (12/29/17 16:26), Minchan Kim wrote:
[..]
> > Gopi Sai Teja, please discuss with Sergey about patch credit.
> 
> Hi Gopi Sai Teja,
> 
> Now I read previous thread at v1 carefully, I found Sergey already
> sent a patch long time ago which is almost same one I suggested.
> And he told he will send a patch soon so I want to wait his patch.
> We are approaching rc6 now so it's not urgent.

Thanks, Minchan.

Sorry for the noise and confusion. I was going to send it out some
time ago, but got interrupted.

> Sergey, sorry for missing your patch at that time.
> Could you resend your patch when you have a time? Please think
> over better name of the function "zs_get_huge_class_size_watermark"

sure, will take a look.

thanks,

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

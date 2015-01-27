Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 812F06B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 22:23:14 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so15598729pab.6
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 19:23:14 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id rk11si14595871pab.99.2015.01.26.19.23.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 19:23:13 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id v10so16073229pde.10
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 19:23:13 -0800 (PST)
Date: Tue, 27 Jan 2015 12:23:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: add log for module load/unload
Message-ID: <20150127032307.GB16797@blaptop>
References: <1422107321-9973-1-git-send-email-opensource.ganesh@gmail.com>
 <20150126151942.2dd88d5221423e7379b43a06@linux-foundation.org>
 <CADAEsF-QuUwdOFhjg9aCLZYPhmuNY-CdXQLgv1V1LXUkcJ8ugg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF-QuUwdOFhjg9aCLZYPhmuNY-CdXQLgv1V1LXUkcJ8ugg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello Ganesh,

On Tue, Jan 27, 2015 at 10:07:53AM +0800, Ganesh Mahendran wrote:
> Hello, Andrew
> 
> 2015-01-27 7:19 GMT+08:00 Andrew Morton <akpm@linux-foundation.org>:
> > On Sat, 24 Jan 2015 21:48:41 +0800 Ganesh Mahendran <opensource.ganesh@gmail.com> wrote:
> >
> >> Sometimes, we want to know whether a module is loaded or unloaded
> >> from the log.
> >
> > Why?  What's special about zsmalloc?
> >
> > Please provide much better justification than this.
> 
> When I debug with the zsmalloc module built in kernel.
> After system boots up, I did not see:
> /sys/kernel/debug/zsmalloc dir.
> 
> Although the reason for this is that I made a mistake. I
> forgot to add debugfs entry in /etc/fstab.
> But I think it is suitable to add information for a module load/unload.
> Then we can get this by:
> dmesg | grep zsmalloc.

I understand your trouble but it's general problem, not zsmalloc specific.
Then, if you really want to fix, you should approach more generic ways.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

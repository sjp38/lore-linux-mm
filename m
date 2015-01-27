Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3486B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 21:07:54 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id z81so10313075oif.2
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:07:53 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id sd4si5756309oeb.37.2015.01.26.18.07.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 18:07:53 -0800 (PST)
Received: by mail-ob0-f175.google.com with SMTP id wp4so11158340obc.6
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:07:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150126151942.2dd88d5221423e7379b43a06@linux-foundation.org>
References: <1422107321-9973-1-git-send-email-opensource.ganesh@gmail.com>
	<20150126151942.2dd88d5221423e7379b43a06@linux-foundation.org>
Date: Tue, 27 Jan 2015 10:07:53 +0800
Message-ID: <CADAEsF-QuUwdOFhjg9aCLZYPhmuNY-CdXQLgv1V1LXUkcJ8ugg@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add log for module load/unload
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello, Andrew

2015-01-27 7:19 GMT+08:00 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 24 Jan 2015 21:48:41 +0800 Ganesh Mahendran <opensource.ganesh@gmail.com> wrote:
>
>> Sometimes, we want to know whether a module is loaded or unloaded
>> from the log.
>
> Why?  What's special about zsmalloc?
>
> Please provide much better justification than this.

When I debug with the zsmalloc module built in kernel.
After system boots up, I did not see:
/sys/kernel/debug/zsmalloc dir.

Although the reason for this is that I made a mistake. I
forgot to add debugfs entry in /etc/fstab.
But I think it is suitable to add information for a module load/unload.
Then we can get this by:
dmesg | grep zsmalloc.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 26A156B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:38:19 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so1112981waf.22
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 06:38:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090128102841.GA24924@barrios-desktop>
References: <20090128102841.GA24924@barrios-desktop>
Date: Wed, 28 Jan 2009 23:38:17 +0900
Message-ID: <2f11576a0901280638w6a18d5fel4997a226a8e924cc@mail.gmail.com>
Subject: Re: [BUG] mlocked page counter mismatch
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

2009/1/28 MinChan Kim <minchan.kim@gmail.com>:
>
> After executing following program, 'cat /proc/meminfo' shows
> following result.
>
> --
> # cat /proc/meminfo
> ..
> Unevictable:           8 kB
> Mlocked:               8 kB
> ..

ok, I'll hand this bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

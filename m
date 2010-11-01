Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 484828D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 18:00:23 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id oA1M0JWq011250
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 15:00:20 -0700
Received: from gwb20 (gwb20.prod.google.com [10.200.2.20])
	by wpaz29.hot.corp.google.com with ESMTP id oA1LxKcj002751
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 15:00:18 -0700
Received: by gwb20 with SMTP id 20so3130678gwb.23
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 15:00:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
Date: Mon, 1 Nov 2010 15:00:14 -0700
Message-ID: <AANLkTi=3mnPWpBB_jehkM6OCyjDwzdwxvyQW9tLQQTC6@mail.gmail.com>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 30, 2010 at 2:35 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi,
>
> We can avoid doing a memset in swap_cgroup_swapon() by using vzalloc().
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Acked-by: Paul Menage <menage@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

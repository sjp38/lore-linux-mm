Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 339686B0088
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 06:41:09 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so25723844pdi.7
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 03:41:08 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id bd4si17100702pad.46.2015.01.11.03.41.06
        for <linux-mm@kvack.org>;
        Sun, 11 Jan 2015 03:41:07 -0800 (PST)
Message-ID: <54B26144.2020008@internode.on.net>
Date: Sun, 11 Jan 2015 22:10:52 +1030
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/rmap.c:399! part 2
References: <54B25F43.6020608@internode.on.net> <54B26044.6070602@amd.com>
In-Reply-To: <54B26044.6070602@amd.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>, linux-mm@kvack.org



Oded Gabbay wrote on 11/01/15 22:06:

> See this thread:
> http://marc.info/?l=linux-kernel&m=142097604508577&w=2
>
> Attached patch.
>
> 	Oded
>

Thanks, applied it and will rebuild kernels in the next few hours.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

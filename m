Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 05E9E6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 03:23:07 -0500 (EST)
Received: by ywh5 with SMTP id 5so45057673ywh.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:23:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
References: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
Date: Mon, 11 Jan 2010 13:53:06 +0530
Message-ID: <d760cf2d1001110023r17a2ed1as6874f02cfb066d8@mail.gmail.com>
Subject: Re: [PATCH] Free memory when create_device is failed
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Kroah-Hartman <greg@kroah.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

On Mon, Jan 11, 2010 at 12:45 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>
>
> I don't know where I send this patch.
> Do I send this patch to akpm or only you and LKML?
>

I think current TO, CC list is okay for this driver.

>
> If create_device is failed, it can't free gendisk and request_queue
> of preceding devices. It cause memory leak.
>
> This patch fixes it.
>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: Nitin Gupta <ngupta@vflare.org>


FWIW,
Acked-by: Nitin Gupta <ngupta@vflare.org>


Thanks for the fix.
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

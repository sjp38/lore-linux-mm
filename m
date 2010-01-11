Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EA1396B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 03:31:10 -0500 (EST)
Received: by pwj10 with SMTP id 10so1580141pwj.6
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:31:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <d760cf2d1001110023r17a2ed1as6874f02cfb066d8@mail.gmail.com>
References: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
	 <d760cf2d1001110023r17a2ed1as6874f02cfb066d8@mail.gmail.com>
Date: Mon, 11 Jan 2010 17:31:08 +0900
Message-ID: <28c262361001110031h70e22f56x2b72a5a7813a6900@mail.gmail.com>
Subject: Re: [PATCH] Free memory when create_device is failed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <greg@kroah.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 11, 2010 at 5:23 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> Hi Minchan,
>
> On Mon, Jan 11, 2010 at 12:45 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>
>> I don't know where I send this patch.
>> Do I send this patch to akpm or only you and LKML?
>>
>
> I think current TO, CC list is okay for this driver.
>
>>
>> If create_device is failed, it can't free gendisk and request_queue
>> of preceding devices. It cause memory leak.
>>
>> This patch fixes it.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> CC: Nitin Gupta <ngupta@vflare.org>
>
>
> FWIW,
> Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks for the ACK, Nitin. :)



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

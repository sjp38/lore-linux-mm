Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id C15636B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:25:16 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id tp5so3578293ieb.5
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 11:25:16 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id yr5si10994454igb.44.2014.01.30.11.25.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 11:25:12 -0800 (PST)
Message-ID: <52EAA714.3080809@infradead.org>
Date: Thu, 30 Jan 2014 11:25:08 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [BUG] Description for memmap in kernel-parameters.txt is wrong
References: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com>
In-Reply-To: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andiry Xu <andiry@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andiry Xu <andiry.xu@gmail.com>, Linux MM <linux-mm@kvack.org>

[adding linux-mm mailing list]

On 01/30/2014 08:52 AM, Andiry Xu wrote:
> Hi,
> 
> In kernel-parameters.txt, there is following description:
> 
> memmap=nn[KMG]$ss[KMG]
>                         [KNL,ACPI] Mark specific memory as reserved.
>                         Region of memory to be used, from ss to ss+nn.

Should be:
                          Region of memory to be reserved, from ss to ss+nn.

but that doesn't help with the problem that you describe, does it?


> Unfortunately this is incorrect. The meaning of nn and ss is reversed.
> For example:
> 
> Command                  Expected                 Result
> memmap 2G$6G        6G - 8G reserved      2G - 8G reserved
> memmap 6G$2G        2G - 8G reserved      6G - 8G reserved

Are you testing on x86?
The code in arch/x86/kernel/e820.c always parses mem_size followed by start address.
I don't (yet) see where it goes wrong...


> Test kernel version 3.13, but I believe the issue has been there long ago.
> 
> I'm not sure whether the description or implementation should be
> fixed, but apparently they do not match.

I prefer to change the documentation and leave the implementation as is.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <3F45B417.6010507@lanil.mine.nu>
Date: Fri, 22 Aug 2003 08:11:35 +0200
From: Christian Axelsson <smiler@lanil.mine.nu>
MIME-Version: 1.0
Subject: Re: [2.6.0-test3-mm3] irda compile error
References: <Pine.LNX.4.44.0308212120380.3006-100000@notebook.home.mdiehl.de>
In-Reply-To: <Pine.LNX.4.44.0308212120380.3006-100000@notebook.home.mdiehl.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Diehl <lists@mdiehl.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Diehl wrote:

>On Thu, 21 Aug 2003, Christian Axelsson wrote:
>
>  
>
>>Got this while doing  make. Config attached.
>>Same config compiles fine under mm2
>>
>> CC      drivers/net/irda/vlsi_ir.o
>>drivers/net/irda/vlsi_ir.c: In function `vlsi_proc_pdev':
>>drivers/net/irda/vlsi_ir.c:167: structure has no member named `name'
>>    
>>
>
>Yep, Thanks. I'm aware of the problem which is due to the recent 
>device->name removal. In fact a fix for this was already included in the 
>latest resent of my big vlsi update patch pending since long.
>
>Anyway, it was pointed out now the patch is too big so I'm currently 
>working on splitting it up. Bunch of patches will follow soon :-)
>
>Btw., are you actually using this driver? I'm always looking for testers 
>with 2.6 to give better real life coverage...
>  
>

No, not until I get a cellphone or similar that I can use it with :)
I smiply have it for eventual cases like this as I want to find as much 
bugs as possible before the actual 2.6 release.

--
Christian Axelsson
smiler@lanil.mine.nu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

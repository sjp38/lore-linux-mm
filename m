Message-ID: <46243CC5.3090501@zachcarter.com>
Date: Mon, 16 Apr 2007 20:19:33 -0700
From: Zach Carter <linux@zachcarter.com>
MIME-Version: 1.0
Subject: Re: BUG:  Bad page state errors during kernel make (resolved)
References: <4622EDD3.9080103@zachcarter.com> <20070416035603.GD21217@redhat.com> <46230A3A.8060907@zachcarter.com> <46240888.1040804@redhat.com>
In-Reply-To: <46240888.1040804@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Ebbert <cebbert@redhat.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> Zach Carter wrote:
>>
>> Do you think there might be other bad hw, or another explanation?
> 

Well, after updating the BIOS for the motherboard, I was able to rebuild the kernel 6 times in a row 
with no page state errors.  I noticed that the recent BIOS update includes "Enhanced compatibility 
with Linux":

	http://www.abit-usa.com/products/mb/bios.php?categories=1&model=316

In case anyone searching the ML archive has the same problem, the motherboard is an ABIT KN9 ULTRA 
Socket AM2 NVIDIA nForce 570 Ultra MCP ATX

-Zach

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

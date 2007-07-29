Message-ID: <46ACC76A.3080303@gmail.com>
Date: Sun, 29 Jul 2007 18:59:22 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46AB166A.2000300@gmail.com>	 <20070728122139.3c7f4290@the-village.bc.nu>	 <46AC4B97.5050708@gmail.com>	 <20070729141215.08973d54@the-village.bc.nu>	 <46AC9F2C.8090601@gmail.com>	 <2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>	 <46ACAB45.6080307@gmail.com>	 <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>	 <46ACB40C.2040908@gmail.com> <2c0942db0707290904n4356582dt91ab96b77db1e84e@mail.gmail.com>
In-Reply-To: <2c0942db0707290904n4356582dt91ab96b77db1e84e@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/29/2007 06:04 PM, Ray Lee wrote:

>> I am very aware of the costs of seeks (on current magnetic media).
> 
> Then perhaps you can just take it on faith -- log structured layouts
> are designed to help minimize seeks, read and write.

I am particularly bad at faith. Let's take that stupid program that I posted:

http://lkml.org/lkml/2007/7/25/85

You push it out before you hit enter, it's written out to swap, at whatever 
speed. How should it be layed out so that it's swapped in most efficiently 
after hitting enter? Reading bigger chunks would quite obviously help, but 
the layout?

The program is not a real-world issue and if you do not consider it a useful 
boundary condition either (okay I guess), how would log structured swap help 
if I just assume I have plenty of free swap to begin with?

Rene.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

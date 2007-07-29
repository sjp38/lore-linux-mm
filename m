Message-ID: <46ACE4E3.9010108@gmail.com>
Date: Sun, 29 Jul 2007 21:05:07 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46AC9F2C.8090601@gmail.com>	 <2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>	 <46ACAB45.6080307@gmail.com>	 <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>	 <46ACB40C.2040908@gmail.com>	 <2c0942db0707290904n4356582dt91ab96b77db1e84e@mail.gmail.com>	 <46ACC76A.3080303@gmail.com>	 <2c0942db0707291019q14f309d0jab3bf083aa37d707@mail.gmail.com>	 <46ACCF7A.1080207@gmail.com> <2c0942db0707291052r79bed95fv30ed6c3badf21338@mail.gmail.com>
In-Reply-To: <2c0942db0707291052r79bed95fv30ed6c3badf21338@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/29/2007 07:52 PM, Ray Lee wrote:

> <Shrug> Well, that doesn't match my systems. My laptop has 400MB in swap:

Which in your case is slightly more than 1/3 of available swap space. Quite 
a lot for a desktop indeed. And if it's more than a few percent fragmented, 
please fix current swapout instead of log structuring it.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

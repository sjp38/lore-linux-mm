Message-ID: <46AAEDEB.7040003@gmail.com>
Date: Sat, 28 Jul 2007 09:19:07 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/27/2007 09:43 PM, david@lang.hm wrote:

> On Fri, 27 Jul 2007, Rene Herman wrote:
> 
>> On 07/27/2007 07:45 PM, Daniel Hazelton wrote:
>>
>>>  Questions about it:
>>>  Q) Does swap-prefetch help with this?
>>>  A) [From all reports I've seen (*)]
>>>  Yes, it does. 
>>
>> No it does not. If updatedb filled memory to the point of causing 
>> swapping (which noone is reproducing anyway) it HAS FILLED MEMORY and 
>> swap-prefetch hasn't any memory to prefetch into -- updatedb itself 
>> doesn't use any significant memory.
> 
> however there are other programs which are known to take up significant 
> amounts of memory and will cause the issue being described (openoffice 
> for example)
> 
> please don't get hung up on the text 'updatedb' and accept that there 
> are programs that do run intermittently and do use a significant amount 
> of ram and then free it.

Different issue. One that's worth pursueing perhaps, but a different issue 
from the VFS caches issue that people have been trying to track down.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

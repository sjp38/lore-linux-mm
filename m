Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Wed, 29 Aug 2001 08:51:59 -0500
Message-Id: <3B8CF2BA.5030506@syntegra.com>
Date: Wed, 29 Aug 2001 08:48:42 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010828000128Z16263-32386+166@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's some 'cut' output from /var/log/messages.  There is a lot more 
from where this came from.  Some of it looks a bit different, I included 
it below the first 3 errors.  I can post the 165k gzipped messages file 
somewhere if someone wants to look at the whole thing.

__alloc_pages: 1-order allocation failed (gfp=0x20/0).
Call Trace: [<c012db70>] [<c012de1e>] [<c012a69e>] [<c012aa21>] 
[<c0211032>]
    [<c02392da>] [<c023669f>] [<c02355c1>] [<c02399a1>] [<c01b000f>] 
[<c011c9bc>]
    [<c01b000f>] [<c02158e6>] [<c021a714>] [<c02158e6>] [<c022173d>] 
[<c0221638>]
    [<c0221b5d>] [<c0211f53>] [<c0221638>] [<c023099a>] [<c0211f53>] 
[<c0211f68>]
    [<c02120b9>] [<c023698e>] [<c0236c65>] [<c023711d>] [<c021f07f>] 
[<c021f40a>]
    [<c01b0571>] [<c0215fae>] [<c0119533>] [<c0108785>] [<c0105230>] 
[<c0105230>]
    [<c0106e34>] [<c0105230>] [<c0105230>] [<c010525c>] [<c01052c2>] 
[<c0105000>]
    [<c010505f>]
__alloc_pages: 1-order allocation failed (gfp=0x20/0).
Call Trace: [<c012db70>] [<c012de1e>] [<c012a69e>] [<c012aa21>] 
[<c0211032>]
    [<c02392da>] [<c023669f>] [<c02399a1>] [<c01b000f>] [<c021a714>] 
[<c02158e6>]
    [<c022173d>] [<c022245d>] [<c0222a83>] [<c0222890>] [<c01e0c9a>] 
[<c01e0e94>]
    [<c01e10f4>] [<c023698e>] [<c0236c65>] [<c023711d>] [<c021f07f>] 
[<c021f40a>]
    [<c01b0571>] [<c0215fae>] [<c0119533>] [<c0108785>] [<c0105230>] 
[<c0105230>]
    [<c0106e34>] [<c0105230>] [<c0105230>] [<c010525c>] [<c01052c2>] 
[<c0105000>]
    [<c010505f>]
__alloc_pages: 1-order allocation failed (gfp=0x20/0).
Call Trace: [<c012db70>] [<c012de1e>] [<c012a69e>] [<c012aa21>] 
[<c0211032>]
    [<c02392da>] [<c023669f>] [<c02399a1>] [<c01b000f>] [<c01b000f>] 
[<c02158e6>]
    [<c021a714>] [<c02158e6>] [<c022173d>] [<c0221638>] [<c0221b5d>] 
[<c0211f53>]
    [<c0221638>] [<c023099a>] [<c0230a4a>] [<c0211dca>] [<c0233137>] 
[<c023698e>]
    [<c0236c65>] [<c023711d>] [<c021f07f>] [<c021f40a>] [<c01b0571>] 
[<c0215fae>]
    [<c0119533>] [<c0108785>] [<c0105230>] [<c0105230>] [<c0106e34>] 
[<c0105230>]
    [<c0105230>] [<c010525c>] [<c01052c2>] [<c01ffaf7>] [<c019266e>]
__alloc_pages: 1-order allocation failed (gfp=0x20/0).



__alloc_pages: 1-order allocation failed (gfp=0x20/0).
Call Trace: [<c012db70>] [<c012de1e>] [<c012a69e>] [<c012aa21>] 
[<c0211032>]
    <3>__alloc_pages: 1-order allocation failed (gfp=0x20/1).
[<c02392da>] Call Trace: [<c023669f>] [<c012db70>] [<c02399a1>] 
[<c012de1e>] [<c01b000f>] [<c012a69e>] [<c021a714>] [<c012aa21>] 
[<c02158e6>] [<c0211032>]

    [<c022173d>] [<c02392da>] [<c0221638>] [<c023669f>] [<c0221b5d>] 
[<c0211032>] [<c0221638>] [<c02399a1>] [<c01e0c9a>] [<c02399a1>] 
[<c01e0e94>] [<c02399a1>]

    [<c01e10f4>] [<c01b000f>] [<c022e9dc>] [<c0112437>] [<c023698e>] 
[<c021a714>] [<c0236c65>] [<c02158e6>] [<c023711d>] [<c01e0c9a>] 
[<c021f07f>] [<c0112437>]

    [<c021f40a>] [<c0112437>] [<c01b0571>] [<c01e10f4>] [<c0215fae>] 
[<c023698e>] [<c0119533>] [<c0236c65>] [<c0108785>] [<c023711d>] 
[<c0105230>] [<c021f07f>]

    [<c0105230>] [<c021f40a>] [<c0106e34>] [<c01b0571>] [<c0105230>] 
[<c0215fae>] [<c0105230>] [<c0119533>] [<c010525c>] [<c0108785>] 
[<c01052c2>] [<c0106e34>]

    [<c01ffaf7>] [<c0120018>] [<c019266e>] [<c012bdfb>]
[<c012beee>] [<c012bf73>] [<c012c04c>] [<c012cf85>]
    [<c012d081>] [<c0105000>] [<c0105573>]


Andy

Daniel Phillips wrote:
> On August 28, 2001 12:28 am, Marcelo Tosatti wrote:
> 
>>On Tue, 28 Aug 2001, Daniel Phillips wrote:
>>
>>>On August 27, 2001 10:14 pm, Andrew Kay wrote:
>>>
>>>>I am having some rather serious problems with the memory management (i 
>>>>think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots 
>>>>of these errors in /var/log/messages.
>>>>
>>Its probably the bounce buffering thingie.
>>
>>I'll send a patch to Linus soon.
>>
> 
> That's what I thought too, but I thought, why not give him the patch and be 
> sure.
> 
> --
> Daniel
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

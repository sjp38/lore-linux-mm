Message-ID: <3D3D96EF.30104@us.ibm.com>
Date: Tue, 23 Jul 2002 10:48:31 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>	<1027377273.5170.37.camel@plars.austin.ibm.com> 	<20020722225251.GG919@holomorphy.com> <1027446044.7699.15.camel@plars.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> On Mon, 2002-07-22 at 17:52, William Lee Irwin III wrote:
> 
>>ISTR this compiler having code generation problems. I think trying to
>>reproduce this with a working i386 compiler is in order, e.g. debian's
>>2.95.4 or some similarly stable version.
> 
> That's exactly the one I was planning on trying it with.  Tried it this
> morning with the same error.  Three compilers later, I think this is
> looking less like a compiler error.  Any ideas?

Exactly _which_ 3 compilers?  I couldn't do it with egcs, but Debian's 
2.5.94 and 3.0 worked.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

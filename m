Message-ID: <3DA65441.7020505@us.ibm.com>
Date: Thu, 10 Oct 2002 21:32:01 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.5.41-mm2
References: <Pine.LNX.4.44.0210100841280.4384-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> On Wed, 9 Oct 2002, Andrew Morton wrote:
>>  Ingo's original per-cpu-pages patch was said to be mainly beneficial
>>  for web-serving type things, but no specweb testing has been possible
>>  for a week or two due to oopses in the timer code.
> 
> i sent my latest timer patch to Dave Hansen but have not heard back since.
> I've attached the latest patch, this kernel also printks a bit more when
> it sees invalid timer usage.
> 
> in any case, the oops Dave was seeing i believe was fixed by Linus (the
> PgUp fix), and it was in the keyboard code. If there's anything else still
> going on then the attached patch should either fix it or provide further
> clues.

Ingo,
   I'm running the current Bitkeeper tree with your patch, with no 
oopses in sight.  The oops happens in seconds without the patch, but I 
haven't seen anything in an hour of running Specweb.  It looks pretty 
good.  Please feed that patch to Linus if you haven't already.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

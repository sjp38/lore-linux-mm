Date: Thu, 7 Jun 2001 16:40:28 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Please test: workaround to help swapoff behaviour
In-Reply-To: <OF4314E00C.5B8A0E4C-ON85256A64.006F54E0@pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0106071606540.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: Mike Galbraith <mikeg@wen-online.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 7 Jun 2001, Bulent Abali wrote:

> 
> I tested your patch against 2.4.5.  It works.  No more lockups.  Without
> the
> patch it took 14 minutes 51 seconds to complete swapoff (this is to recover
> 1.5GB of
> swap space).  During this time the system was frozen.  No keyboard, no
> screen, etc. Practically locked-up.
> 
> With the patch there are no more lockups. Swapoff kept running in the
> background.
> This is a winner.
>
> But here is the caveat: swapoff keeps burning 100% of the cycles until it
> completes.

Yup. Wait a while until the dead swap cache issue is sorted out. 

When that finally happens, the time spent in swapoff will probably be
"acceptable".

> This is not going to be a big deal during shutdowns.  Only when you enter
> swapoff from
> the command line it is going to be a problem.
> 
> I looked at try_to_unuse in swapfile.c.  I believe that the algorithm is
> broken.

Yes. 

> For each and every swap entry it is walking the entire process list
> (for_each_task(p)).  It is also grabbing a whole bunch of locks
> for each swap entry.  It might be worthwhile processing swap entries in
> batches instead of one entry at a time.

The real fix is to make the processing the other way around --- go looking
into the pte's and from there do the swapins. 

Don't have the time to do everything, though. :) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

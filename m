Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <20050116043639.GE24653@blackham.com.au>
References: <20050113085626.GA5374@blackham.com.au>
	 <20050113101426.GA4883@blackham.com.au> <41E8ED89.8090306@yahoo.com.au>
	 <1105785254.13918.4.camel@desktop.cunninghams>
	 <41E8F313.4030102@yahoo.com.au>
	 <1105786115.13918.9.camel@desktop.cunninghams>
	 <41E8F7F7.1010908@yahoo.com.au> <20050115124018.GA24653@blackham.com.au>
	 <20050115125311.GA19055@blackham.com.au> <41E9E5B6.1020306@yahoo.com.au>
	 <20050116043639.GE24653@blackham.com.au>
Content-Type: text/plain
Message-Id: <1105851404.21576.4.camel@laptop.cunninghams>
Mime-Version: 1.0
Date: Sun, 16 Jan 2005 15:56:44 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernard Blackham <bernard@blackham.com.au>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Sun, 2005-01-16 at 15:36, Bernard Blackham wrote:
> On Sun, Jan 16, 2005 at 02:55:34PM +1100, Nick Piggin wrote:
> > Someone asked for an order 10 allocation by the looks.
> > 
> > This might tell us what happened.
> 
> Yep. Attached. Appears Software Suspend is asking for it as part of
> it's memory grab. Perhaps wakeup_kswapd just needs to be disabled
> while suspending? Nigel?

That makes sense. Okay: Nick, does it look like an issue that affects
swsusp (in kernel version) as well? If not, we can stop bugging you, and
I'll add an appropriate test to stop it acting on the basis of our
grabbing of memory while suspending. (FYI, we seek to grab all available
memory while preparing the image so that we can get some stability in
the numbers and (if we really do need to eat some memory), make headway
while leaving other processes thawed. (ie we use the vm pressure to get
memory freed until we meet our constraints).

Regards,

Nigel
-- 
Nigel Cunningham
Software Engineer
Cyclades Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

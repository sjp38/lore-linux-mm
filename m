Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 075A66B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 23:26:05 -0400 (EDT)
Date: Fri, 26 Aug 2011 11:26:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Message-ID: <20110826032601.GA26282@localhost>
References: <4E5494D4.1050605@profihost.ag>
 <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
 <4E54BDCF.9020504@profihost.ag>
 <20110824093336.GB5214@localhost>
 <4E560F2A.1030801@profihost.ag>
 <20110826021648.GA19529@localhost>
 <4E570AEB.1040703@profihost.ag>
 <20110826030313.GA24058@localhost>
 <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe <s.priebe@profihost.ag>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

On Fri, Aug 26, 2011 at 11:13:07AM +0800, Stefan Priebe wrote:
> 
> >> There is at least a numastat proc file.
> > 
> > Thanks. This shows that node0 is accessed 10x more than node1.
> 
> What can i do to prevent this or isn't this normal when a machine mostly idles so processes are mostly processed by cpu0.

Yes, that's normal. However it should explain why it's slow even when
there are lots of free pages _globally_.

> > 
> >> complete ps output:
> >> http://pastebin.com/raw.php?i=b948svzN
> > 
> > In that log, scp happens to be in R state and also no other tasks in D
> > state. Would you retry in the hope of catching some stucked state?
> Sadly not as the sysrq trigger has rebootet the machine and it will now run fine for 1 or 2 days.

Oops, sorry! It might be possible to reproduce the issue by manually
eating all of the memory with sparse file data:

        truncate -s 1T 1T
        cp 1T /dev/null

> > 
> >>>         echo t>  /proc/sysrq-trigger
> >> sadly i wa sonly able to grab the output in this crazy format:
> >> http://pastebin.com/raw.php?i=MBXvvyH1
> > 
> > It's pretty readable dmesg, except that the data is incomplete and
> > there are nothing valuable in the uploaded portion..
> That was everything i could grab through netconsole. Is there a better way?

netconsole is enough.  The partial output should be due to the reboot...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

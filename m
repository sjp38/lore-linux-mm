Message-ID: <3BAFA2CA.FAA0D9CB@earthlink.net>
Date: Mon, 24 Sep 2001 21:16:58 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Process not given >890MB on a 4MB machine ?????????
References: <5D2F375D116BD111844C00609763076E050D1680@exch-staff1.ul.ie>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Gabriel.Leen" wrote:
> 
> Hello again,
> And thanks,
> 
>         >You will either need to use a true 64-bit machine (POWER, Alpha,
>         >UltraSPARC or MIPS)
> 
> I hope (fingers crossed) that there is some way around this
> I think that Redhat  now supports up to 64GB of ram,
> as the Xeon has 36 address lines, see attached.
> 
> I'm only grasping at straws here, but I hope that it is somehow possible
> on this machine?

No. You still only get a maximum of 4GB of -virtual- space per
process. The machine can address up to 64GB of -physical- RAM,
but a single process (actually a single page directory) can
see only 4GB at a time. Sorry :-(

-- Joe
# Replace the pink stuff with net to reply.
# "You know how many remote castles there are along the
#  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
# Linux MM docs:
http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Wed, 7 Aug 2002 15:07:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: oom_killer - Does not perform when stress-tested (system hangs)
Message-ID: <20020807220733.GV6256@holomorphy.com>
References: <OFDE4A1CCD.14106609-ON65256C0E.0057D9B9@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <OFDE4A1CCD.14106609-ON65256C0E.0057D9B9@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Srikrishnan Sundararajan <srikrishnan@in.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2002 at 10:31:21PM +0530, Srikrishnan Sundararajan wrote:
> I used a PC with Linux -2.4.7-10 (RH 7.2). RAM:128 MB, Swap: 256 MB. I run
> as an user and not as root.
> Is this expected behavior? Is it the responsibility of the user not to
> "fill" the memory? Could oom_killer not take care of such a stress-test?
> Should any thing warn the user when swap-space is full?

Can you reproduce this with 2.4.19, 2.4.19-ac, 2.4.19-rmap, or 2.5.30?


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

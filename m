Date: Fri, 29 Dec 2000 16:19:28 -0500
From: Gregory Maxwell <greg@linuxpower.cx>
Subject: Re: 2.2.19pre3 and poor reponse to RT-scheduled processes?
Message-ID: <20001229161927.A560@xi.linuxpower.cx>
References: <200012292045.PAA17190@ninigret.metatel.office>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200012292045.PAA17190@ninigret.metatel.office>; from rafal.boni@eDial.com on Fri, Dec 29, 2000 at 03:45:23PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rafal Boni <rafal.boni@eDial.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 29, 2000 at 03:45:23PM -0500, Rafal Boni wrote:
[snip]
> 	The box in question is running the linux-ha.org heartbeat package,
> 	which is a RT-scheduled, mlock()'ed process, and as such should
> 	get as good service as the box is able to mange.  Often, under
> 	high disk (and/or MM) loads, the box becomes unreponsive for a
> 	period of time from ~ 1 sec to a high of ~ 2.8sec.
[snip]

You are running IDE aren't you?

Enable DMA and/or unmask interupts.

man hdparm

Good luck.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

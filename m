Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9370A60080B
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:18:08 -0400 (EDT)
Date: Tue, 24 Aug 2010 08:18:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [stable] "vmscan: raise the bar to PAGEOUT_IO_SYNC stalls" to
 stable?
Message-ID: <20100824001802.GA6568@localhost>
References: <4C639E87.3050805@suse.cz>
 <20100819060516.GA14221@localhost>
 <20100819103139.GA31206@develbox.linuxbox.cz>
 <20100823222216.GB13371@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100823222216.GB13371@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Nikola Ciprich <extmaillist@linuxbox.cz>, LKML <linux-kernel@vger.kernel.org>, "nikola.ciprich@linuxbox.cz" <nikola.ciprich@linuxbox.cz>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pedro Ribeiro <pedrib@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, "stable@kernel.org" <stable@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 06:22:16AM +0800, Greg KH wrote:
> On Thu, Aug 19, 2010 at 12:31:39PM +0200, Nikola Ciprich wrote:
> > Hello everybody,
> > is there any chance this one could also make it to long term
> > supported 2.6.32 series?
> > I guess this will take more work, but I guess there are quite
> > a few users that would appreciate it much :)
> 
> It seems to also apply and build successfully on .32-stable, so I've
> queued it up there as well.

Yup, thanks! The patch can be used unmodified on .32.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

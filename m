Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E13196B004F
	for <linux-mm@kvack.org>; Sat, 17 Oct 2009 01:42:26 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <200910152142.02876.elendil@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <200910150402.03953.elendil@planet.nl> <1255620567.21134.162.camel@rc-desk>
	 <200910152142.02876.elendil@planet.nl>
Content-Type: multipart/mixed; boundary="=-L8++X/qq33fGC3FNSUi7"
Date: Fri, 16 Oct 2009 22:42:23 -0700
Message-Id: <1255758143.21134.1360.camel@rc-desk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--=-L8++X/qq33fGC3FNSUi7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Frans,

On Thu, 2009-10-15 at 12:41 -0700, Frans Pop wrote:
> On Thursday 15 October 2009, reinette chatre wrote:
> > > The log file timestamps don't tell much as the logging gets delayed,
> > > so they all end up at the same time. Maybe I should enable the kernel
> > > timestamps so we can see how far apart these failures are.
> >
> > If you can get accurate timing it will be very useful. I am interested
> > to see how quickly it goes from "48 free buffers" to "0 free buffers".
> 
> Attached the dmesg for three consecutive test runs (i.e. without 
> rebooting). Not that the 2nd one includes only "0 free buffers" messages, 
> even though the behavior (point where desktop freezes and music stops) 
> looked similar.
> 
> Not sure if you can tell all that much from the data.
> 

Prompted by this thread we are in process of moving allocation to paged
skb. This will definitely reduce the allocation size (from order 2 to
order 1) and hopefully help with this problem also. Could you please try
with the attached two patches? They are based on 2.6.32-rc4.

Thank you very much

Reinette






--=-L8++X/qq33fGC3FNSUi7
Content-Disposition: attachment; filename="0001-iwlwifi-use-paged-Rx.patch"
Content-Type: text/x-patch; name="0001-iwlwifi-use-paged-Rx.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


--=-L8++X/qq33fGC3FNSUi7--

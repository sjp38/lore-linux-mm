Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 58AE66B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:15:18 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <200910271210.31014.elendil@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <200910152142.02876.elendil@planet.nl>
	 <1255758143.21134.1360.camel@rc-desk>
	 <200910271210.31014.elendil@planet.nl>
Content-Type: text/plain
Date: Tue, 27 Oct 2009 09:15:16 -0700
Message-Id: <1256660116.21134.9172.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Frans,

On Tue, 2009-10-27 at 04:10 -0700, Frans Pop wrote:
> Sorry for the delay in replying.
> 
> On Saturday 17 October 2009, reinette chatre wrote:
> > Prompted by this thread we are in process of moving allocation to paged
> > skb. This will definitely reduce the allocation size (from order 2 to
> > order 1) and hopefully help with this problem also. Could you please try
> > with the attached two patches? They are based on 2.6.32-rc4.
> 
> Looks very good! With these patches I no longer get any SKB allocation 
> errors, even during the heaviest freezes while gitk is loading. I do still 
> get (long) music skips during the freezes, but that's not unexpected.
> AFAICT the wireless connection is stable.
> 
> Tested on top of current mainline git: v2.6.32-rc5-81-g964fe08.
> 
> Please add, if you feel it's appropriate, my:
> Reported-and-tested-by: Frans Pop <elendil@planet.nl>

Thank you very much for testing these patches so thoroughly. They are
both on their way upstream already so I am not able to add your
signature at this time. Since these are pretty big changes these patches
will be in 2.6.33.

Reinette


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

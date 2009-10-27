Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7ED766B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 08:54:47 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 5/5] ONLY-APPLY-IF-STILL-FAILING Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs read/write confusion
Date: Tue, 27 Oct 2009 11:29:01 +0100
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-6-git-send-email-mel@csn.ul.ie> <20091026235628.2F7B.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091026235628.2F7B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200910271129.05586.elendil@planet.nl>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 27 October 2009, KOSAKI Motohiro wrote:
> Oops. no, please no.
> 8aa7e847 is regression fixing commit. this revert indicate the
> regression occur again.
> if we really need to revert it, we need to revert 1faa16d2287 too.
> however, I doubt this commit really cause regression to iwlan. IOW,
> I agree Jens.

This is not intended as a patch for mainline, but just as a test to see if 
it improves things. It may be a regression fix, but it also creates a 
significant change in behavior during swapping in my test case.
If a fix is needed, it will probably by different from this revert.
Please read: http://lkml.org/lkml/2009/10/26/510.

This mail has some data: http://lkml.org/lkml/2009/10/26/455.

> I hope to try reproduce this problem on my test environment. Can anyone
> please explain reproduce way?

Please see my mails in this thread for bug #14141: 
http://thread.gmane.org/gmane.linux.kernel/896714

You will probably need to read some of them to understand the context of 
the two mails linked above.

The most relevant ones are (all from the same thread; not sure why gmane 
gives such weird links):
http://article.gmane.org/gmane.linux.kernel.mm/39909
http://article.gmane.org/gmane.linux.kernel.kernel-testers/7228
http://article.gmane.org/gmane.linux.kernel.kernel-testers/7165

> Is special hardware necessary?

Not special hardware, but you may need an encrypted partition and NFS; the 
test may need to be modified according to the amount of memory you have.
I think it should be possible to reproduce the freezes I see while ignoring 
the SKB allocation errors as IMO those are just a symptom, not the cause.
So you should not need wireless.

The severity of the freezes during my test often increases if the test is 
repeated (without rebooting).

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

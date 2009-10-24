From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
  failures V2
Date: Sat, 24 Oct 2009 09:48:19 +0300
Message-ID: <4AE2A333.6060307__7798.41309781677$1256366957$gmane$org@cs.helsinki.fi>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com> <alpine.DEB.1.10.0910232151380.2001@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CBC0C6B004F
	for <linux-mm@kvack.org>; Sat, 24 Oct 2009 02:49:01 -0400 (EDT)
In-Reply-To: <alpine.DEB.1.10.0910232151380.2001@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,  " <linux-mm@kvack.org>,	akpm@linux-foundation.
List-Id: linux-mm.kvack.org

On Thu, 22 Oct 2009, Pekka Enberg wrote:
>> These are pretty obvious bug fixes and should go to linux-next ASAP IMHO.

Christoph Lameter wrote:
> Bug fixes go into main not linux-next. Lets make sure these fixes really
> work and then merge.

Regardless, patches 1-2 and should _really_ go to Linus' tree (and 
eventually -stable) while we figure out the rest of the problems. They 
fix obvious regressions in the code paths and we have reports from 
people that they help. Yes, they don't fix everything for everyone but 
we there's no upside in holding back fixes that are simple one line 
fixes to regressions.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

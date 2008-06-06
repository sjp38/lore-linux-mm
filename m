Date: Thu, 5 Jun 2008 20:21:32 -0700
From: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Subject: Re: [PATCH 0/3 v2] per-task-delay-accounting: add memory reclaim
 delay
Message-Id: <20080605202132.d84b7083.kobayashi.kk@ncos.nec.co.jp>
In-Reply-To: <48489E71.2060708@linux.vnet.ibm.com>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp>
	<48489E71.2060708@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 07:48:25 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> >     $ ./delayget -d -p <pid>
> >     CPU             count     real total  virtual total    delay total
> >                      2640     2456153500     2478353004       28366219
> >     IO              count    delay total
> >                      2628    19894214188
> >     SWAP            count    delay total
> >                         0              0
> >     RECLAIM         count    delay total
> >                      6600    10682486085
> > 
> 
> Looks interesting, this data is for the whole system or memcgroup? If it is for
> memcgroup, we should be using cgroupstats.

Thanks for your comment.
This accounting, which is named "RECLAIM", is global and memcgroup reclaim delay
and this data is value per task.

Unfortunately, I'm not sure what the whole system means.
Could you tell me your point?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

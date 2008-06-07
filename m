Date: Sat, 07 Jun 2008 13:44:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3 v2] per-task-delay-accounting: update taskstats for memory reclaim delay
In-Reply-To: <20080606172437.bcd7d98a.kobayashi.kk@ncos.nec.co.jp>
References: <4848B983.4030502@linux.vnet.ibm.com> <20080606172437.bcd7d98a.kobayashi.kk@ncos.nec.co.jp>
Message-Id: <20080607134129.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Add members for memory reclaim delay to taskstats,
> and accumulate them in __delayacct_add_tsk() .
> 
> Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
> ---
> 
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Two suggested changes
> >
> > 1. Please add all fields at the end (otherwise we risk breaking compatibility)
> > 2. please also update Documentation/accounting/taskstats-struct.txt
> >
> 
> Thanks for your suggestion.
> Update version is here.
> 
> In taskstats-struct.txt, there was not a discription for "Time accounting for SMT machines".
> This patch was made after the following patch had been applied.
> http://lkml.org/lkml/2008/6/6/436 .

The code of this patch looks good to me.
but this change log isn't so good.

Do you want remain email bare discssion on git log?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

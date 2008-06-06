Message-ID: <4849B2EC.5070405@ct.jp.nec.com>
Date: Fri, 06 Jun 2008 14:58:04 -0700
From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3 v2] per-task-delay-accounting: update taskstats for
 memory reclaim delay
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp> <20080605163220.8397bed6.kobayashi.kk@ncos.nec.co.jp> <4848B983.4030502@linux.vnet.ibm.com>
In-Reply-To: <4848B983.4030502@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Keika Kobayashi wrote:
>> Add members for memory reclaim delay to taskstats,
>> and accumulate them in __delayacct_add_tsk() .
>>
>> Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
> 
> Two suggested changes
> 
> 1. Please add all fields at the end (otherwise we risk breaking compatibility)
> 2. please also update Documentation/accounting/taskstats-struct.txt
> 
And update TASKSTATS_VERSION, right?

Thanks,
Hiroshi Shimamoto

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

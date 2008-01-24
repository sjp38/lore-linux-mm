Date: Thu, 24 Jan 2008 12:19:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <20080123102222.GA21455@csn.ul.ie>
References: <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123102222.GA21455@csn.ul.ie>
Message-Id: <20080124121310.175B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi

> To rule it out, can you also try with the patch below applied please? It
> should only make a difference on sparsemem so if discontigmem is still
> crashing, there is likely another problem. Assuming it crashes, 

Aaah, sorry.
I can't test again until next week.

I repost at that time...


> please
> post the full dmesg output with loglevel=8 on the command line. Thanks

You are right..
I omitted it at previous mail, sorry.

because piking up dmesg is very difficult when boot time crash. ;-)


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

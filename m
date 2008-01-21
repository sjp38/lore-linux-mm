Date: Mon, 21 Jan 2008 09:38:50 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
Message-Id: <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi 

> A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> at the restrictions on setting NUMA on x86 to see if they could be lifted.

Interesting!

I will test tomorrow.
I think this patch become easy to the porting of fakenuma.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 15 Nov 2007 15:39:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][ for -mm] memory controller enhancements for NUMA [0/10]
 introduction
Message-Id: <20071115153936.69cc7e76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <473BE66E.2000707@linux.vnet.ibm.com>
References: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
	<473BE66E.2000707@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 11:55:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Hi, KAMEZAWA-San,
> 
> Thanks for the patchset, I'll review it and get back. I'd
> also try and get some testing done on it.
> 
Hi, thank you.

I'm now writing per-zone-lru-lock patches and reflects comments from YAMAMOTO-san.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

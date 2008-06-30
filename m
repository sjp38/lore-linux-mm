Date: Mon, 30 Jun 2008 13:19:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
Message-Id: <20080630131920.68d2cc23.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48685A72.3090102@linux.vnet.ibm.com>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
	<20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com>
	<4867174B.3090005@linux.vnet.ibm.com>
	<20080630102054.ee214765.kamezawa.hiroyu@jp.fujitsu.com>
	<486855DF.2070100@linux.vnet.ibm.com>
	<20080630125737.4b14785f.kamezawa.hiroyu@jp.fujitsu.com>
	<48685A72.3090102@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jun 2008 09:30:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Hmm, that is the case where "share" works well. Why soft-limit ?
> > i/o conroller doesn't support share ? (I don' know sorry.)
> > 
> 
> Share is a proportional allocation of a resource. Typically that resource is
> soft-limits, but not necessarily. If we re-use resource counters, my expectation
> is that
> 
> A share implementation would under-neath use soft-limits.
> 
Hmm...I don't convice at this point. (because it's future problem)
At least, please find lock-less approach to check soft-limit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

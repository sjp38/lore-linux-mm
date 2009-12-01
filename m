Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCD7600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 05:40:45 -0500 (EST)
Message-ID: <4B14F29E.3090400@parallels.com>
Date: Tue, 01 Dec 2009 13:40:30 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com> <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com> <20091126085031.GG2970@balbir.in.ibm.com> <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com> <4B0E461C.50606@parallels.com> <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com> <4B0E50B1.20602@parallels.com> <20091201073609.GQ2970@balbir.in.ibm.com>
In-Reply-To: <20091201073609.GQ2970@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Just to understand the context better, is this really a problem. This
> can occur when we do really run out of memory. The idea of using
> slabcg + memcg together is good, except for our accounting process. I
> can repost percpu counter patches that adds fuzziness along with other
> tricks that Kame has to do batch accounting, that we will need to
> make sure we are able to do with slab allocations as well.
> 

I'm not sure I understand you concern. Can you elaborate, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

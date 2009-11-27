Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 15E056B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 04:48:34 -0500 (EST)
Message-ID: <4B0FA060.4050907@parallels.com>
Date: Fri, 27 Nov 2009 12:48:16 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>	 <20091126113209.5A68.A69D9226@jp.fujitsu.com> <604427e00911262301tac7f55avedd44263fbabccc2@mail.gmail.com>
In-Reply-To: <604427e00911262301tac7f55avedd44263fbabccc2@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ying Han wrote:
> I kind of like the idea to have a kernel memory controller instead of
> kernel slab controller.
> If we only count kernel slabs, do we need another mechanism to count
> kernel allocations
> directly from get_free_pages() ?

We do. Look at what get_free_pages we mark with GFP_UBC in beancounters
and see, that if we don't count them this creates way to DoS the kernel.

> --Ying
>>
>> Thanks.
>>
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

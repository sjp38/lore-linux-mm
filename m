Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mAAFpjVn013646
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 10:51:45 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAAFpReL053906
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 10:51:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAAFpCg3029658
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 10:51:13 -0500
Subject: Re: [BUGFIX][PATCH] memcg: memory hotplug fix
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20081110183839.e551a52e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081110183839.e551a52e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 10 Nov 2008 07:52:35 -0800
Message-Id: <1226332355.8805.6.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-11-10 at 18:38 +0900, KAMEZAWA Hiroyuki wrote:
> This is a bug fix reported against 2.6.28-rc3 from Badari.
> Badari, could you give me Ack or Tested-by ?
> 
> Thanks,
> -Kame
> ==
> start pfn calculation of page_cgroup's memory hotplug notifier chain
> is wrong.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Tested-by: Badari Pulavarty <pbadari@us.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

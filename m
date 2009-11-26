Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9600C6B0088
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 05:13:35 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id nAQADKH2028348
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:13:21 GMT
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz24.hot.corp.google.com with ESMTP id nAQADIoh026094
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:13:18 -0800
Received: by pzk5 with SMTP id 5so413828pzk.18
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:13:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091126085031.GG2970@balbir.in.ibm.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091126085031.GG2970@balbir.in.ibm.com>
Date: Thu, 26 Nov 2009 02:13:17 -0800
Message-ID: <d26f1ae00911260213t3e389ccfqa03d18c459210b2e@mail.gmail.com>
Subject: Re: memcg: slab control
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@openvz.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/26/09, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  I think it is easier to write a slab controller IMHO.

One potential problem I can think of with writing a slab controller
would be that the user would have to estimate what fraction of the
amount of memory slab should be allowed to use, which might not be
ideal.

If you wanted to limit a cgroup to a total of 1GB of memory, you might
not care if the job wants to use 0.9 GB of user memory and 0.1GB of
slab or if it wants to use 0.9GB of slab and 0.1GB of user memory..

Because of this, it might be more practical to integrate the slab
accounting in memcg.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

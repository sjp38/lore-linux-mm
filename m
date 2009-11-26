Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9135B6B0087
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 05:01:37 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id nAQA1Wtm025785
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:01:33 GMT
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by wpaz9.hot.corp.google.com with ESMTP id nAQA1TCU028482
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:01:30 -0800
Received: by pwi15 with SMTP id 15so410942pwi.4
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 02:01:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091126101704.879a1b15.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	 <20091126101704.879a1b15.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 Nov 2009 02:01:29 -0800
Message-ID: <d26f1ae00911260201u6d6d8e21wf4af7179101717b8@mail.gmail.com>
Subject: Re: memcg: slab control
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 11/25/09, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> BTW, how much percent of pages are used for slab in Google system ?
>  Because memory size is going bigger and bigger, ratio of slab usage is going
>  smaller, I think.

It varies.
The amount of slab on systems can go from negligible to being a
significant portion of the total memory (in network intensive
workloads, for example).

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

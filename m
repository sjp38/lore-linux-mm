Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 250786B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:23:52 -0400 (EDT)
Received: by dakp5 with SMTP id p5so148991dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:23:51 -0700 (PDT)
Date: Wed, 20 Jun 2012 18:23:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: do not schedule if current has been killed
In-Reply-To: <4FE11B6C.6020706@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206201823380.3702@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com> <20120619135551.GA24542@redhat.com>
 <alpine.DEB.2.00.1206191323470.17985@chino.kir.corp.google.com> <alpine.DEB.2.00.1206191358030.21795@chino.kir.corp.google.com> <4FE0F1A9.7050607@gmail.com> <4FE11B6C.6020706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 20 Jun 2012, Kamezawa Hiroyuki wrote:

> I'll check memcg part to make it consistent to this when this goes to -mm.
> 

It's merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

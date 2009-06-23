Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 237AC6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 00:18:53 -0400 (EDT)
Date: Mon, 22 Jun 2009 21:19:27 -0700 (PDT)
Message-Id: <20090622.211927.245716932.davem@davemloft.net>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
 from DCCP
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090623023936.GA2721@ghostprotocols.net>
References: <1245685414-8979-4-git-send-email-mel@csn.ul.ie>
	<20090622.161502.74508182.davem@davemloft.net>
	<20090623023936.GA2721@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: acme@redhat.com
Cc: mel@csn.ul.ie, akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 22 Jun 2009 23:39:36 -0300

> Em Mon, Jun 22, 2009 at 04:15:02PM -0700, David Miller escreveu:
>> It's probably much more appropriate to make this stuff use
>> alloc_large_system_hash(), like TCP does (see net/ipv4/tcp.c
>> tcp_init()).
>> 
>> All of this complicated DCCP hash table size computation code will
>> simply disappear.  And it'll fix the warning too :-)
> 
> He mentioned that in the conversation that lead to this new patch
> series, problem is that alloc_large_system_hash is __init, so when you
> try to load dccp.ko it will not be available.

Fair enough.

It's such an unfortunate duplication of code, it's likely therefore
better to remove the __init tag and export that symbol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

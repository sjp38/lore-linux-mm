Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F3F86B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 07:04:34 -0400 (EDT)
Message-ID: <4A40B69A.2020703@gmail.com>
Date: Tue, 23 Jun 2009 13:03:54 +0200
From: Eric Dumazet <eric.dumazet@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
 from DCCP
References: <1245685414-8979-4-git-send-email-mel@csn.ul.ie>	<20090622.161502.74508182.davem@davemloft.net>	<20090623023936.GA2721@ghostprotocols.net> <20090622.211927.245716932.davem@davemloft.net>
In-Reply-To: <20090622.211927.245716932.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: acme@redhat.com, mel@csn.ul.ie, akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

David Miller a ecrit :
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Mon, 22 Jun 2009 23:39:36 -0300
> 
>> Em Mon, Jun 22, 2009 at 04:15:02PM -0700, David Miller escreveu:
>>> It's probably much more appropriate to make this stuff use
>>> alloc_large_system_hash(), like TCP does (see net/ipv4/tcp.c
>>> tcp_init()).
>>>
>>> All of this complicated DCCP hash table size computation code will
>>> simply disappear.  And it'll fix the warning too :-)
>> He mentioned that in the conversation that lead to this new patch
>> series, problem is that alloc_large_system_hash is __init, so when you
>> try to load dccp.ko it will not be available.
> 
> Fair enough.
> 
> It's such an unfortunate duplication of code, it's likely therefore
> better to remove the __init tag and export that symbol.

Agreed, I once considered using this function for futex hash table allocation
and just forgot about it...

But it has some bootmem references, it might need more work than just exporting it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

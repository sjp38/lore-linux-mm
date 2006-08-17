Message-ID: <44E3E964.8010602@google.com>
Date: Wed, 16 Aug 2006 20:58:28 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins> <20060813215853.0ed0e973.akpm@osdl.org>
In-Reply-To: <20060813215853.0ed0e973.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>>Testcase:
>>
>>Mount an NBD device as sole swap device and mmap > physical RAM, then
>>loop through touching pages only once.
> 
> Fix: don't try to swap over the network.  Yes, there may be some scenarios
> where people have no local storage, but it's reasonable to expect anyone
> who is using Linux as an "enterprise storage platform" to stick a local
> disk on the thing for swap.
> 
> That leaves MAP_SHARED, but mm-tracking-shared-dirty-pages.patch will fix
> that, will it not?

Hi Andrew,

What happened to the case where we just fill memory full of dirty file
pages backed by a remote disk?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

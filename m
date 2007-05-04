Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
From: Daniel Walker <dwalker@mvista.com>
In-Reply-To: <20070504102651.923946304@chello.nl>
References: <20070504102651.923946304@chello.nl>
Content-Type: text/plain
Date: Fri, 04 May 2007 08:22:59 -0700
Message-Id: <1178292179.7997.12.camel@imap.mvista.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 12:26 +0200, Peter Zijlstra wrote:

> 1) introduce the memory reserve and make the SLAB allocator play nice with it.
>    patches 01-10
> 
> 2) add some needed infrastructure to the network code
>    patches 11-13
> 
> 3) implement the idea outlined above
>    patches 14-20
> 
> 4) teach the swap machinery to use generic address_spaces
>    patches 21-24
> 
> 5) implement swap over NFS using all the new stuff
>    patches 25-31
> 
> 6) implement swap over iSCSI
>    patches 32-40

This is kind of a lot of patches all at once .. Have you release any of
these patch sets prior to this release ? 

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

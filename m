Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D845A6B0072
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 12:24:57 -0400 (EDT)
Date: Thu, 30 Aug 2012 12:24:53 -0400 (EDT)
Message-Id: <20120830.122453.1449291050128191766.davem@davemloft.net>
Subject: Re: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120823141740.GA30305@phenom.dumpdata.com>
References: <20120808.155046.820543563969484712.davem@davemloft.net>
	<1345631207.6821.140.camel@zakaz.uk.xensource.com>
	<20120823141740.GA30305@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com
Cc: Ian.Campbell@citrix.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, xen-devel@lists.xensource.com, konrad@darnok.org, akpm@linux-foundation.org

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 23 Aug 2012 10:17:40 -0400

> On Wed, Aug 22, 2012 at 11:26:47AM +0100, Ian Campbell wrote:
>> On Wed, 2012-08-08 at 23:50 +0100, David Miller wrote:
>> > Just use something like a call to __pskb_pull_tail(skb, len) and all
>> > that other crap around that area can simply be deleted.
>> 
>> I think you mean something like this, which works for me, although I've
>> only lightly tested it.
>> 
> 
> I've tested it heavily and works great.
> 
> Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> and I took a look at it too and:
> 
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Applied, thanks everyone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

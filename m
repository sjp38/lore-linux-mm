Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id CB1116B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:26:53 -0400 (EDT)
Message-ID: <1345631207.6821.140.camel@zakaz.uk.xensource.com>
Subject: Re: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 22 Aug 2012 11:26:47 +0100
In-Reply-To: <20120808.155046.820543563969484712.davem@davemloft.net>
References: <20120807085554.GF29814@suse.de>
	 <20120808.155046.820543563969484712.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "konrad@darnok.org" <konrad@darnok.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, 2012-08-08 at 23:50 +0100, David Miller wrote:
> Just use something like a call to __pskb_pull_tail(skb, len) and all
> that other crap around that area can simply be deleted.

I think you mean something like this, which works for me, although I've
only lightly tested it.

Ian.

8<----------------------------------------

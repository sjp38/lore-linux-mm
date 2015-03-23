Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B12146B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:35:41 -0400 (EDT)
Received: by pagv19 with SMTP id v19so25939700pag.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:35:41 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id dp4si2368394pdb.101.2015.03.23.12.35.40
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 12:35:40 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:35:37 -0400 (EDT)
Message-Id: <20150323.153537.1167433221134028872.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <55104EAA.4060607@oracle.com>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<55104EAA.4060607@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: David Ahern <david.ahern@oracle.com>
Date: Mon, 23 Mar 2015 11:34:34 -0600

> seems like a formality at this point, but this resolves the panic on
> the M7-based ldom and baremetal. The T5-8 failed to boot, but it could
> be a different problem.

Specifically, does the T5-8 boot without my patch applied?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

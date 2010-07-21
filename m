Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 83A226B02A7
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 23:30:45 -0400 (EDT)
Date: Tue, 20 Jul 2010 20:31:00 -0700 (PDT)
Message-Id: <20100720.203100.254885062.davem@davemloft.net>
Subject: Re: [patch 1/6] sparc: remove dependency on __GFP_NOFAIL
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.DEB.2.00.1007201938100.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1007201938100.8728@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: rientjes@google.com
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: David Rientjes <rientjes@google.com>
Date: Tue, 20 Jul 2010 19:44:53 -0700 (PDT)

> The kmalloc() in mdesc_kmalloc() is failable, so remove __GFP_NOFAIL from
> its mask.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

The __GFP_NOFAIL is there intentionally.

The code above this, in the cases where the machine description is
dynamically updated by the hypervisor at run time, long after boot,
has no failure handling.

We absolutely must accept the machine descriptor update and fetch it
from the hypervisor into a new buffer.

Please don't remove this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

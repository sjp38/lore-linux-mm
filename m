Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E26B6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 13:20:10 -0400 (EDT)
Date: Fri, 01 May 2009 10:20:22 -0700 (PDT)
Message-Id: <20090501.102022.149412194.davem@davemloft.net>
Subject: Re: [PATCH 2.6.30] Doc: hashdist defaults on for 64bit
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0905011442540.19247@blonde.anvils>
References: <20090429142825.6dcf233d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0905011354560.19012@blonde.anvils>
	<Pine.LNX.4.64.0905011442540.19247@blonde.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, andi@firstfloor.org, anton@samba.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 1 May 2009 14:45:43 +0100 (BST)

> Update Doc: kernel boot parameter hashdist now defaults on for all 64bit NUMA.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 395AE6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 04:11:38 -0500 (EST)
Date: Mon, 25 Feb 2013 04:11:37 -0500 (EST)
From: Aaron Tomlin <atomlin@redhat.com>
Message-ID: <1972662987.7786576.1361783497483.JavaMail.root@redhat.com>
In-Reply-To: <512775CA.2030603@parallels.com>
Subject: Re: [PATCH] mm: slab: Verify the nodeid passed to
 ____cache_alloc_node
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik <riel@redhat.com>

> If you assert with VM_BUG_ON, it will be active on debugging kernels
> only, which I believe is better suited for a hotpath.

Agreed.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

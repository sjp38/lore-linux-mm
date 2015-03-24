Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB946B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 12:05:27 -0400 (EDT)
Received: by pagj7 with SMTP id j7so2597336pag.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:05:26 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id a17si6247164pbu.75.2015.03.24.09.05.25
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 09:05:26 -0700 (PDT)
Date: Tue, 24 Mar 2015 12:05:22 -0400 (EDT)
Message-Id: <20150324.120522.577453784216935829.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150324145753.GC10685@zareason>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<20150324145753.GC10685@zareason>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bpicco@meloft.net
Cc: david.ahern@oracle.com, torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Bob Picco <bpicco@meloft.net>
Date: Tue, 24 Mar 2015 10:57:53 -0400

> Seems solid with 2.6.39 on M7-4. Jalap?no is happy with current sparc.git.

Thanks for all the testing, it's been integrated into the -stable
queues as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

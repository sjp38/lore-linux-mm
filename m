Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0553E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:19:45 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so106154358pab.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:19:44 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id on8si10953831pdb.242.2015.03.20.13.19.44
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 13:19:44 -0700 (PDT)
Date: Fri, 20 Mar 2015 16:19:41 -0400 (EDT)
Message-Id: <20150320.161941.18622997855089870.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <550C7AE1.1000808@oracle.com>
References: <550C6151.8070803@oracle.com>
	<20150320.154700.1250039074828760104.davem@davemloft.net>
	<550C7AE1.1000808@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org

From: David Ahern <david.ahern@oracle.com>
Date: Fri, 20 Mar 2015 13:54:09 -0600

> Interesting. With -j <64 and talking softly it completes. But -j 128
> and higher always ends in a panic.

Please share more details of your configuration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

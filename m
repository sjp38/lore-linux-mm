Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA266B04CF
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 10:17:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so2499086pgs.9
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 07:17:13 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id 66si4100196pld.784.2018.01.05.07.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 07:17:12 -0800 (PST)
Date: Fri, 05 Jan 2018 10:17:06 -0500 (EST)
Message-Id: <20180105.101706.344316131945042174.davem@davemloft.net>
Subject: Re: [PATCH 8/8] net: tipc: remove unused hardirq.h
From: David Miller <davem@davemloft.net>
In-Reply-To: <b48afbb6-771f-84b1-8329-d5941eff086b@alibaba-inc.com>
References: <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
	<4ed1efbc-5fb8-7412-4f46-1e3a91a98373@windriver.com>
	<b48afbb6-771f-84b1-8329-d5941eff086b@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.s@alibaba-inc.com
Cc: linux-kernel@vger.kernel.org, ying.xue@windriver.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, jon.maloy@ericsson.com

From: "Yang Shi" <yang.s@alibaba-inc.com>
Date: Fri, 05 Jan 2018 06:46:48 +0800

> Any more comment on this change?

These patches were not really submitted properly.

If you post a series, the series goes to one destination and
one tree.

If they are supposed to go to multiple trees, submit them
individually rather than as a series.  With clear indications
in the Subject lines which tree should be taking the patch.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5DBE280257
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 12:50:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so733894565pgc.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:50:56 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id r85si34698115pfr.254.2016.12.23.09.50.55
        for <linux-mm@kvack.org>;
        Fri, 23 Dec 2016 09:50:55 -0800 (PST)
Date: Fri, 23 Dec 2016 12:50:53 -0500 (EST)
Message-Id: <20161223.125053.1340469257610308679.davem@davemloft.net>
Subject: Re: [net/mm PATCH v2 0/3] Page fragment updates
From: David Miller <davem@davemloft.net>
In-Reply-To: <20161223170756.14573.74139.stgit@localhost.localdomain>
References: <20161223170756.14573.74139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.duyck@gmail.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 23 Dec 2016 09:16:39 -0800

> I tried to get in touch with Andrew about this fix but I haven't heard any
> reply to the email I sent out on Tuesday.  The last comment I had from
> Andrew against v1 was "Looks good to me.  I have it all queued for post-4.9
> processing.", but I haven't received any notice they were applied.

Andrew, please follow up with Alex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

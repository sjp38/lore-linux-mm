Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0196A828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:21:43 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so86608429pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:21:42 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id 21si4029455pfl.36.2016.01.13.12.21.41
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 12:21:42 -0800 (PST)
Date: Wed, 13 Jan 2016 15:21:38 -0500 (EST)
Message-Id: <20160113.152138.454507206353287548.davem@davemloft.net>
Subject: Re: [PATCH v5 7/7] sparc64: mm/gup: add gup trace points
From: David Miller <davem@davemloft.net>
In-Reply-To: <569693B4.6060305@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
	<1449696151-4195-8-git-send-email-yang.shi@linaro.org>
	<569693B4.6060305@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linaro.org
Cc: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, sparclinux@vger.kernel.org

From: "Shi, Yang" <yang.shi@linaro.org>
Date: Wed, 13 Jan 2016 10:13:08 -0800

> Any comment on this one? The tracing part review has been done.

I thought this was going to simply be submitted upstream via
another tree.

If you just want my ack then:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

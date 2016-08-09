Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B56AB6B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 19:29:21 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so46755382pab.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 16:29:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y8si45028142pae.172.2016.08.09.16.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 16:29:20 -0700 (PDT)
Date: Tue, 9 Aug 2016 16:29:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: optimize find_zone_movable_pfns_for_nodes to avoid
 unnecessary loop.
Message-Id: <20160809162919.266e58ca0c33896dcf417a02@linux-foundation.org>
In-Reply-To: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com>
References: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 5 Aug 2016 22:04:07 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> when required_kernelcore decrease to zero, we should exit the loop in time.
> because It will waste time to scan the remainder node.

The patch is rather ugly and it only affects __init code, so the only
benefit will be to boot time.

Do we have any timing measurements which would justify changing this code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

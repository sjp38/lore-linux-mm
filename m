Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7153B6B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 13:19:31 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so1409214eaj.0
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:19:30 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id s8si13740141eeh.17.2013.12.21.10.19.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Dec 2013 10:19:30 -0800 (PST)
Date: Sat, 21 Dec 2013 19:19:29 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/memory-failure.c: transfer page count from head
 page to tail page after split thp
Message-ID: <20131221181929.GG20765@two.firstfloor.org>
References: <1387444174-16752-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387444174-16752-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> Cc: stable@vger.kernel.org # 3.9+
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Looks good.

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

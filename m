Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id D19DA6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 15:34:19 -0500 (EST)
Received: by igkb16 with SMTP id b16so49297486igk.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 12:34:19 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id e9si9682063ioj.105.2015.03.05.12.34.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 12:34:19 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so49153102igb.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 12:34:19 -0800 (PST)
Date: Thu, 5 Mar 2015 12:34:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: pagewalk: prevent positive return value of
 walk_page_test() from being passed to callers (Re: [PATCH] mm: fix do_mbind
 return value)
In-Reply-To: <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
Message-ID: <alpine.DEB.2.10.1503051233280.23808@chino.kir.corp.google.com>
References: <54F7BD54.5060502@gmail.com> <alpine.DEB.2.10.1503042231250.15901@chino.kir.corp.google.com> <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 5 Mar 2015, Naoya Horiguchi wrote:

> walk_page_test() is purely pagewalk's internal stuff, and its positive return
> values are not intended to be passed to the callers of pagewalk. However, in
> the current code if the last vma in the do-while loop in walk_page_range()
> happens to return a positive value, it leaks outside walk_page_range().
> So the user visible effect is invalid/unexpected return value (according to
> the reporter, mbind() causes it.)
> 
> This patch fixes it simply by reinitializing the return value after checked.
> 
> Another exposed interface, walk_page_vma(), already returns 0 for such cases
> so no problem.
> 
> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
> Reported-by: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

This is exactly what I had in mind, thanks for fixing it up so fast!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

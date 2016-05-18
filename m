Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2316C6B025F
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:03:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so29886995wme.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:03:41 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id h64si33510408wmf.112.2016.05.18.07.03.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 07:03:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 594E798D10
	for <linux-mm@kvack.org>; Wed, 18 May 2016 14:03:39 +0000 (UTC)
Date: Wed, 18 May 2016 15:03:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm: check_new_page_bad() directly returns in
 __PG_HWPOISON case
Message-ID: <20160518140337.GG2527@techsingularity.net>
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160518092100.GB2527@techsingularity.net>
 <573C365B.6020807@suse.cz>
 <20160518100949.GA17299@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160518100949.GA17299@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, May 18, 2016 at 10:09:50AM +0000, Naoya Horiguchi wrote:
> From c600b1ee6c36b3df6973f5365b4179c92f3c08e3 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 18 May 2016 18:42:57 +0900
> Subject: [PATCH v2] mm: check_new_page_bad() directly returns in __PG_HWPOISON
>  case
> 
> Currently we check page->flags twice for "HWPoisoned" case of
> check_new_page_bad(), which can cause a race with unpoisoning.
> This race unnecessarily taints kernel with "BUG: Bad page state".
> check_new_page_bad() is the only caller of bad_page() which is interested
> in __PG_HWPOISON, so let's move the hwpoison related code in bad_page()
> to it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

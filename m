Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD046B0253
	for <linux-mm@kvack.org>; Fri, 20 May 2016 10:27:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so14211684wma.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 07:27:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ju6si25968427wjb.182.2016.05.20.07.27.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 07:27:15 -0700 (PDT)
Subject: Re: [PATCH v2] mm: check_new_page_bad() directly returns in
 __PG_HWPOISON case
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160518092100.GB2527@techsingularity.net> <573C365B.6020807@suse.cz>
 <20160518100949.GA17299@hori1.linux.bs1.fc.nec.co.jp>
 <20160518140337.GG2527@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573F1EC0.6030801@suse.cz>
Date: Fri, 20 May 2016 16:27:12 +0200
MIME-Version: 1.0
In-Reply-To: <20160518140337.GG2527@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 05/18/2016 04:03 PM, Mel Gorman wrote:
> On Wed, May 18, 2016 at 10:09:50AM +0000, Naoya Horiguchi wrote:
>>  From c600b1ee6c36b3df6973f5365b4179c92f3c08e3 Mon Sep 17 00:00:00 2001
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Date: Wed, 18 May 2016 18:42:57 +0900
>> Subject: [PATCH v2] mm: check_new_page_bad() directly returns in __PG_HWPOISON
>>   case
>>
>> Currently we check page->flags twice for "HWPoisoned" case of
>> check_new_page_bad(), which can cause a race with unpoisoning.
>> This race unnecessarily taints kernel with "BUG: Bad page state".
>> check_new_page_bad() is the only caller of bad_page() which is interested
>> in __PG_HWPOISON, so let's move the hwpoison related code in bad_page()
>> to it.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
>
Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

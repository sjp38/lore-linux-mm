Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDC06B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 13:33:45 -0400 (EDT)
Received: by ieqy10 with SMTP id y10so80255522ieq.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 10:33:45 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id k10si2103091igx.32.2015.06.26.10.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 10:33:44 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so80114442iec.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 10:33:44 -0700 (PDT)
In-Reply-To: <1435339686.15762.2.camel@stgolabs.net>
References: <1435335335-16007-1-git-send-email-xerofoify@gmail.com> <1435339686.15762.2.camel@stgolabs.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH] mm:Make the function vma_has_reserves bool
From: Nicholas Krause <xerofoify@gmail.com>
Date: Fri, 26 Jun 2015 13:34:34 -0400
Message-ID: <2E352578-4D2D-483D-871B-72AC8FE2B83A@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, mike.kravetz@oracle.com, lcapitulino@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On June 26, 2015 1:28:06 PM EDT, Davidlohr Bueso <dave@stgolabs.net> wrote:
>On Fri, 2015-06-26 at 12:15 -0400, Nicholas Krause wrote:
>> This makes the function vma_has_reserves bool now due to this
>> particular function only returning either one or zero as its
>> return value.
>> 
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  mm/hugetlb.c | 12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>
>Yeah, don't be sending one patch per function change for this kind of
>crap.
Sure no problem.  Is this applied however. 
Nick
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

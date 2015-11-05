Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B7AF082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:16:14 -0500 (EST)
Received: by wmww144 with SMTP id w144so11025991wmw.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:14 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id g72si9466279wmd.70.2015.11.05.08.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:16:13 -0800 (PST)
Received: by wmnn186 with SMTP id n186so18740646wmn.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:12 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH 0/3] __GFP_REPEAT cleanup
Date: Thu,  5 Nov 2015 17:15:57 +0100
Message-Id: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
while working on something unrelated I've checked the current usage
of __GFP_REPEAT in the tree. It seems that a good half of it is
and always has been bogus because __GFP_REPEAT has always been about
high order allocations while we are using it for order-0 or very small
orders very often. It seems that a big pile of them is just a copy&paste
when a code has been adopted from one arch to another.

I think it makes some sense to get rid of them because they are just
making the semantic more unclear.

The series is based on linux-next tree and
$ git grep __GFP_REPEAT next/master | wc -l
106

and with the patch
$ git grep __GFP_REPEAT  | wc -l
44

There are probably more users which do not need the flag but I have focused
on the trivially superfluous ones here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 26A8F6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:42:50 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so97021938pab.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:42:49 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id ld16si17014282pab.16.2015.10.22.14.42.49
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 14:42:49 -0700 (PDT)
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
 <5629579B.8050507@oracle.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56295858.1090301@sr71.net>
Date: Thu, 22 Oct 2015 14:42:48 -0700
MIME-Version: 1.0
In-Reply-To: <5629579B.8050507@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On 10/22/2015 02:39 PM, Sasha Levin wrote:
> Trinity seems to be able to hit the newly added warnings pretty easily:

Kirill reported the same thing.  Is it fixed with this applied?

> http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlb-use-memory-policy-when-available-fix.patch


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

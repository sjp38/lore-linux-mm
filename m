Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BDA9782F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 14:20:52 -0500 (EST)
Received: by pasz6 with SMTP id z6so26839623pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 11:20:52 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ov1si1670911pbb.110.2015.11.03.11.20.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 11:20:52 -0800 (PST)
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
 <5629579B.8050507@oracle.com> <56295858.1090301@sr71.net>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56390723.80203@oracle.com>
Date: Tue, 3 Nov 2015 14:12:35 -0500
MIME-Version: 1.0
In-Reply-To: <56295858.1090301@sr71.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On 10/22/2015 05:42 PM, Dave Hansen wrote:
> On 10/22/2015 02:39 PM, Sasha Levin wrote:
>> > Trinity seems to be able to hit the newly added warnings pretty easily:
> Kirill reported the same thing.  Is it fixed with this applied?
> 
>> > http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlb-use-memory-policy-when-available-fix.patch

Yup, that works for me.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

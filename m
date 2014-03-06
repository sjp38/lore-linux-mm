Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id C32066B0037
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:16:37 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f73so3330694yha.14
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:16:37 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s36si12455051yhh.89.2014.03.06.13.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:16:37 -0800 (PST)
Message-ID: <5318E5AD.9090107@oracle.com>
Date: Thu, 06 Mar 2014 16:16:29 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
References: <53126861.7040107@oracle.com> <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5314E0CD.6070308@oracle.com> <5314F661.30202@oracle.com> <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com> <531657DC.4050204@oracle.com> <1393976967-lnmm5xcs@n-horiguchi@ah.jp.nec.com> <5317FA3B.8060900@oracle.com> <1394122113-xsq3i6vw@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394122113-xsq3i6vw@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On 03/06/2014 11:08 AM, Naoya Horiguchi wrote:
> And I found my patch was totally wrong because it should check
> !pte_present(), not pte_present().
> I'm testing fixed one (see below), and the problem seems not to reproduce
> in my environment at least for now.
> But I'm not 100% sure, so I need your double checking.

Nope, I still see the problem. Same NULL deref and trace as before.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

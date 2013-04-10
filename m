Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 60F636B0027
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:30:57 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ML100DN33J6UBD0@mailout1.samsung.com> for
 linux-mm@kvack.org; Wed, 10 Apr 2013 16:30:55 +0900 (KST)
From: Chanho Park <chanho61.park@samsusng.com>
References: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
 <20130405111158.GA13428@e103986-lin>
In-reply-to: <20130405111158.GA13428@e103986-lin>
Subject: RE: [PATCH] arm: mm: lockless get_user_pages_fast
Date: Wed, 10 Apr 2013 16:30:54 +0900
Message-id: <00a201ce35bd$5626fd90$0274f8b0$@samsusng.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Steve Capper' <steve.capper@arm.com>, 'Chanho Park' <chanho61.park@samsung.com>
Cc: linux@arm.linux.org.uk, 'Catalin Marinas' <Catalin.Marinas@arm.com>, 'Inki Dae' <inki.dae@samsung.com>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Myungjoo Ham' <myungjoo.ham@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Grazvydas Ignotas' <notasas@gmail.com>

> Apologies for the tardy response, this patch slipped past me.

Never mind.

> I've tested this patch out, unfortunately it treats huge pmds as regular
> pmds and attempts to traverse them rather than fall back to a slow path.
> The fix for this is very minor, please see my suggestion below.
OK. I'll fix it.

> 
> As an aside, I would like to extend this fast_gup to include full huge
> page support and include a __get_user_pages_fast implementation. This will
> hopefully fix a problem that was brought to my attention by Grazvydas
> Ignotas whereby a FUTEX_WAIT on a THP tail page will cause an infinite
> loop due to the stock implementation of __get_user_pages_fast always
> returning 0.

I'll add the __get_user_pages_fast implementation. BTW, HugeTLB on ARM
wasn't
supported yet. There is no problem to add gup_huge_pmd. But I think it need
a test
for hugepages.

> I would suggest:
> 		if (pmd_none(*pmdp) || pmd_bad(*pmdp))
> 			return 0;
> as this will pick up pmds that can't be traversed, and fall back to the
> slow path.

Thanks for your suggestion.
I'll prepare the v2 patch.

Best regards,
Chanho Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

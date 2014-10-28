Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 247C5900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 16:40:19 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1445715pdb.41
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:40:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y3si2309001pdm.95.2014.10.28.13.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 13:40:18 -0700 (PDT)
Date: Tue, 28 Oct 2014 13:40:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same
 as normal zero page.
Message-Id: <20141028134018.f317ed1d0bc4043cf9b4a3b7@linux-foundation.org>
In-Reply-To: <20141028133539.c82f5e856fd66b39c2630dd4@linux-foundation.org>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
	<20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
	<20141028154416.GB13840@gmail.com>
	<20141028133539.c82f5e856fd66b39c2630dd4@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengwei Yin <yfw.kernel@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, 28 Oct 2014 13:35:39 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > Hi Andrew,
> > Please try this patch.
> > It passed build with/without CONFIG_TRANSPARENT_HUGEPAGE. Thanks.
> 
> You didn't answer my question.

Ah, yes you did, in another email, sorry.

I see Kirill has a different patch for you to review and test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

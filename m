Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 596666B0055
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 20:28:21 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so11823170veb.11
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:28:21 -0700 (PDT)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id l2si4157426vcf.151.2014.04.16.17.28.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 17:28:20 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id lh14so11414262vcb.6
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:28:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140416084236.GA23247@node.dhcp.inet.fi>
References: <1397598536-25074-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAA_GA1ecVD2GuxvPqBhGKdUfMeBJU+m-i5XeSzMmDXy=QncLqA@mail.gmail.com>
	<20140416084236.GA23247@node.dhcp.inet.fi>
Date: Thu, 17 Apr 2014 08:28:20 +0800
Message-ID: <CAA_GA1d1uKtqAxhgzx-pwkymvndmJb4PpMLQZHcetvgf16vBeg@mail.gmail.com>
Subject: Re: [PATCH] thp: close race between split and zap huge pages
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Apr 16, 2014 at 4:42 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Apr 16, 2014 at 07:52:29AM +0800, Bob Liu wrote:
>> >         *ptl = pmd_lock(mm, pmd);
>> > -       if (pmd_none(*pmd))
>> > +       if (!pmd_present(*pmd))
>> >                 goto unlock;
>>
>> But I didn't get the idea why pmd_none() was removed?
>
> !pmd_present(*pmd) is weaker check then pmd_none(*pmd). I mean if
> pmd_none(*pmd) is true then pmd_present(*pmd) is always false.

Oh, yes. That's right.

BTW, it looks like this bug was introduced by the same reason.
https://lkml.org/lkml/2014/4/16/403

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

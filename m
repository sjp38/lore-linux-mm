Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 51D046B02A8
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 07:58:08 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l126so263260239wml.0
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 04:58:08 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id y7si29402799wmb.15.2015.12.28.04.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 04:58:07 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id l126so268220787wml.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 04:58:06 -0800 (PST)
Date: Mon, 28 Dec 2015 14:58:04 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] thp: fix regression in handling mlocked pages in
 __split_huge_pmd()
Message-ID: <20151228125804.GA5284@node.shutemov.name>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
 <567C978E.3090007@oracle.com>
 <CAPcyv4gc-iGNvLHRQxP4NAGc1u41jbCVnZ=iwgpLSNN3Dw7=uw@mail.gmail.com>
 <567C991B.3000408@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <567C991B.3000408@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Thu, Dec 24, 2015 at 08:17:15PM -0500, Sasha Levin wrote:
> On 12/24/2015 08:12 PM, Dan Williams wrote:
> > On Thu, Dec 24, 2015 at 5:10 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> >> > On 12/24/2015 06:51 AM, Kirill A. Shutemov wrote:
> >>> >> This patch fixes regression caused by patch
> >>> >>  "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"
> >>> >>
> >>> >> The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
> >>> >> __split_huge_pmd_locked(). It can never succeed, since the pmd already
> >>> >> points to a page table. As result the page is never get munlocked.
> >>> >>
> >>> >> It causes crashes like this:
> >>> >>  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
> >> >
> >> > So this patch didn't fix the issue for me. I've sent Kirill the trace
> >> > off-list, but it's essentially the same thing.
> > Can you send me the trace as well, and the reproducer?
> 
> I don't have a simple reproducer, it reproduces rather quickly when running
> under trinity within a KVM guest running a kernel I've attached the config
> for.

Is there a chance to get it reproduced with logs enabled in trinity?
I failed to repoproduce it and code audit isn't fruitful so far.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

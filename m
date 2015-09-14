Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF486B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:58:28 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so143029227pac.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 04:58:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qj5si22988258pac.65.2015.09.14.04.58.26
        for <linux-mm@kvack.org>;
        Mon, 14 Sep 2015 04:58:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150914105346.GB23878@arm.com>
References: <20150914105346.GB23878@arm.com>
Subject: RE: LTP regressions due to 6dc296e7df4c ("mm: make sure all file VMAs
 have ->vm_ops set")
Content-Transfer-Encoding: 7bit
Message-Id: <20150914115800.06242CE@black.fi.intel.com>
Date: Mon, 14 Sep 2015 14:57:59 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: kirill.shutemov@linux.intel.com, oleg@redhat.com, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Will Deacon wrote:
> Hi Kirill,
> 
> Your patch 6dc296e7df4c ("mm: make sure all file VMAs have ->vm_ops set")
> causes some mmap regressions in LTP, which appears to use a MAP_PRIVATE
> mmap of /dev/zero as a way to get anonymous pages in some of its tests
> (specifically mmap10 [1]).
> 
> Dead simple reproducer below. Is this change in behaviour intentional?

Ouch. Of couse it's a bug.

Fix is below. I don't really like it, but I cannot find any better
solution.

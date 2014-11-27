Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 524DA6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 10:08:11 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so16016890wiv.11
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 07:08:10 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id jo9si12343716wjc.128.2014.11.27.07.08.10
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 07:08:10 -0800 (PST)
Date: Thu, 27 Nov 2014 17:08:05 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [LSF/MM TOPIC] Transparent huge pages: refcounting, page cache,
 scalability
Message-ID: <20141127150805.GA27093@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, hughd@google.com

Hello,

I would like to have discussion on future of transparent huge pages.
I work on better refcounting for THP[1] which should help to overcome some
scalability issues and make semantics around split_huge_page() simpler.

It's also step toward THP in page cache: unlike my previous attempt on the
topic with new refcounting we will not need new lock in io path to protect
against splitting.

[1] http://article.gmane.org/gmane.linux.kernel.mm/124862

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

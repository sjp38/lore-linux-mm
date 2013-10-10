Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7346B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:34:03 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so3139453pad.0
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:34:03 -0700 (PDT)
Date: Thu, 10 Oct 2013 14:33:57 -0400 (EDT)
Message-Id: <20131010.143357.1529669202244130105.davem@davemloft.net>
Subject: Re: [PATCH 27/34] sparc: handle pgtable_page_ctor() fail
From: David Miller <davem@davemloft.net>
In-Reply-To: <1381428359-14843-28-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1381428359-14843-28-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Thu, 10 Oct 2013 21:05:52 +0300

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0E6E6B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 16:50:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i185so4083009wmi.7
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:50:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 6si6434697wmt.84.2017.06.29.13.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 13:50:53 -0700 (PDT)
Date: Thu, 29 Jun 2017 13:50:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp, mm: Fix crash due race in MADV_FREE handling
Message-Id: <20170629135051.e864cb987584c0d6fa7a074e@linux-foundation.org>
In-Reply-To: <20170628101550.7uybtgfaejtxd7jv@node.shutemov.name>
References: <20170628101249.17879-1-kirill.shutemov@linux.intel.com>
	<20170628101550.7uybtgfaejtxd7jv@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Wed, 28 Jun 2017 13:15:50 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Reinette Chatre <reinette.chatre@intel.com>
> > Fixes: 9818b8cde622 ("madvise_free, thp: fix madvise_free_huge_pmd return value after splitting")
> 
> Sorry, the wrong Fixes. The right one:
> 
> Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")

So I'll add cc:stable, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

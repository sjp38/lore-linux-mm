Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA1926B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 23:30:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l81so5223041wmg.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:30:26 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id a17si5114077wra.327.2017.06.29.20.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 20:30:25 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id 62so98548830wmw.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:30:25 -0700 (PDT)
Date: Fri, 30 Jun 2017 06:30:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp, mm: Fix crash due race in MADV_FREE handling
Message-ID: <20170630033022.vzryosqtzw3xxqfc@node.shutemov.name>
References: <20170628101249.17879-1-kirill.shutemov@linux.intel.com>
 <20170628101550.7uybtgfaejtxd7jv@node.shutemov.name>
 <20170629135051.e864cb987584c0d6fa7a074e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629135051.e864cb987584c0d6fa7a074e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Jun 29, 2017 at 01:50:51PM -0700, Andrew Morton wrote:
> On Wed, 28 Jun 2017 13:15:50 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Reported-by: Reinette Chatre <reinette.chatre@intel.com>
> > > Fixes: 9818b8cde622 ("madvise_free, thp: fix madvise_free_huge_pmd return value after splitting")
> > 
> > Sorry, the wrong Fixes. The right one:
> > 
> > Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")
> 
> So I'll add cc:stable, OK?

Yep.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

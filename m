Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7C66B27F6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:44:09 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 3-v6so11066881plc.18
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 14:44:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b34si7417064pld.305.2018.11.21.14.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 14:44:07 -0800 (PST)
Date: Wed, 21 Nov 2018 14:44:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/gup: finish consolidating error handling
Message-Id: <20181121144404.efdab6dbccd7780034a55e1d@linux-foundation.org>
In-Reply-To: <20181121081402.29641-2-jhubbard@nvidia.com>
References: <20181121081402.29641-1-jhubbard@nvidia.com>
	<20181121081402.29641-2-jhubbard@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, 21 Nov 2018 00:14:02 -0800 john.hubbard@gmail.com wrote:

> Commit df06b37ffe5a4 ("mm/gup: cache dev_pagemap while pinning pages")
> attempted to operate on each page that get_user_pages had retrieved. In
> order to do that, it created a common exit point from the routine.
> However, one case was missed, which this patch fixes up.
> 
> Also, there was still an unnecessary shadow declaration (with a
> different type) of the "ret" variable, which this patch removes.
> 

What is the bug which this supposedly fixes and what is that bug's
user-visible impact?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90B8B6B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:57:47 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id l10so29828210ioi.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:57:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v12si28252698ita.52.2017.06.01.02.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 02:57:46 -0700 (PDT)
Date: Thu, 1 Jun 2017 12:57:43 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Message-ID: <20170601095743.uldzfnpew7vyq4rn@black.fi.intel.com>
References: <20170531150349.4816-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170531150349.4816-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, May 31, 2017 at 11:03:49AM -0400, Jerome Glisse wrote:
> Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
> we no longer cleanup stall pgd entries and thus the BUG_ON() inside
> sync_global_pgds() is wrong.
> 
> This patch remove the BUG_ON() and unconditionaly update stall pgd
> entries.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
